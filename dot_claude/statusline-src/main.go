// Claude Code statusline.
// Reads JSON session data from stdin, prints a single-line, colored, Nerd Font statusline.
// Built native: no shell version issues, native UTF-8.
package main

import (
	"crypto/sha1"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"io"
	"os"
	"os/exec"
	"os/user"
	"path/filepath"
	"strings"
	"time"
)

// Input mirrors the subset of the statusline JSON schema this program cares about.
type Input struct {
	CWD   string `json:"cwd"`
	Model struct {
		DisplayName string `json:"display_name"`
	} `json:"model"`
	Workspace struct {
		CurrentDir  string `json:"current_dir"`
		ProjectDir  string `json:"project_dir"`
		GitWorktree string `json:"git_worktree"`
	} `json:"workspace"`
	ContextWindow struct {
		TotalInputTokens  int     `json:"total_input_tokens"`
		TotalOutputTokens int     `json:"total_output_tokens"`
		ContextWindowSize int     `json:"context_window_size"`
		UsedPercentage   *float64 `json:"used_percentage"`
	} `json:"context_window"`
	Cost struct {
		TotalCostUSD    *float64 `json:"total_cost_usd"`
		TotalDurationMS *int     `json:"total_duration_ms"`
	} `json:"cost"`
	Effort struct {
		Level string `json:"level"`
	} `json:"effort"`
	Thinking struct {
		Enabled bool `json:"enabled"`
	} `json:"thinking"`
	OutputStyle struct {
		Name string `json:"name"`
	} `json:"output_style"`
	Vim struct {
		Mode string `json:"mode"`
	} `json:"vim"`
	RateLimits struct {
		FiveHour struct {
			UsedPercentage *float64 `json:"used_percentage"`
		} `json:"five_hour"`
		SevenDay struct {
			UsedPercentage *float64 `json:"used_percentage"`
		} `json:"seven_day"`
	} `json:"rate_limits"`
	Worktree struct {
		Name string `json:"name"`
	} `json:"worktree"`
	Agent struct {
		Name string `json:"name"`
	} `json:"agent"`
	Exceeds200K   bool   `json:"exceeds_200k_tokens"`
	PermissionMode string `json:"permission_mode"` // not currently in schema; future-proofed
}

// ANSI helpers
const (
	reset = "\x1b[0m"
	bold  = "\x1b[1m"
	dim   = "\x1b[2m"
)

func fg(n int) string { return fmt.Sprintf("\x1b[38;5;%dm", n) }

var (
	cCyan      = fg(81)
	cGreen     = fg(114)
	cYellow    = fg(221)
	cMagenta   = fg(183)
	cGray      = fg(245)
	cBlue      = fg(110)
	cSoftGreen = fg(150)
	cAmber     = fg(214)
	cPurple    = fg(141)
	cRed       = fg(203)
)

// Nerd Font glyphs, all in the BMP PUA (U+E000\u2013U+F8FF) as 4-digit \u escapes.
// No plane-15 (U+F0000+) glyphs: JetBrains' terminal mis-measures those as
// double-width and corrupts the input line. Stick to BMP Font Awesome / Dev / Octicons.
const (
	gModel  = "\uf2db" // nf-fa-microchip
	gDir    = "\uf07c" // nf-fa-folder_open
	gBranch = "\ue0a0" // nf-dev-git_branch
	gCtx    = "\uf0e7" // nf-fa-bolt
	gVim    = "\ueb62" // nf-cod-symbol_keyword
	gCost   = "\uefca" // nf-fa-money_check_dollar
	gRate   = "\uf463" // nf-oct-meter
	gThink  = "\uee9c" // nf-fa-brain
	gTime   = "\uf017" // nf-fa-clock_o
	gWT     = "\uf126" // nf-fa-code_fork
	gAgent  = "\uf21b" // nf-fa-user_secret
)

// Statusline rendering separator.
var sep = cGray + "│" + reset

func main() {
	data, err := io.ReadAll(os.Stdin)
	if err != nil || len(data) == 0 {
		os.Exit(0)
	}

	var in Input
	if err := json.Unmarshal(data, &in); err != nil {
		// Print nothing on parse error so the terminal doesn't show garbage.
		os.Exit(0)
	}

	segs := buildSegments(&in)
	fmt.Println(strings.Join(segs, " "+sep+" "))
}

// buildSegments composes the ordered list of rendered segments.
func buildSegments(in *Input) []string {
	var out []string

	// Model
	model := strings.TrimSpace(strings.TrimPrefix(in.Model.DisplayName, "Claude "))
	if model == "" {
		model = "Claude"
	}
	out = append(out, bold+cMagenta+gModel+" "+model+reset)

	// Directory
	dir := firstNonEmpty(in.Workspace.CurrentDir, in.CWD)
	if dir != "" {
		out = append(out, cCyan+gDir+" "+displayDir(dir)+reset)
	}

	// Git branch (cached)
	if branch := gitBranch(dir, in.Workspace.GitWorktree); branch != "" {
		out = append(out, cGreen+gBranch+" "+truncate(branch, 35)+reset)
	}

	// Context window
	if in.ContextWindow.UsedPercentage != nil {
		pct := int(*in.ContextWindow.UsedPercentage + 0.5)
		color := cBlue
		if pct >= 80 {
			color = cRed
		} else if pct >= 50 {
			color = cYellow
		}
		seg := fmt.Sprintf("%s%s %d%%%s", color, gCtx, pct, reset)
		if in.ContextWindow.TotalInputTokens > 0 && in.ContextWindow.ContextWindowSize > 0 {
			seg += " " + cGray + fmtTokens(in.ContextWindow.TotalInputTokens+in.ContextWindow.TotalOutputTokens) +
				"/" + fmtTokens(in.ContextWindow.ContextWindowSize) + reset
		}
		if in.Exceeds200K {
			seg += " " + cRed + "!200k" + reset
		}
		out = append(out, seg)
	}

	// Cost
	if in.Cost.TotalCostUSD != nil && *in.Cost.TotalCostUSD > 0 {
		out = append(out, cSoftGreen+gCost+" "+fmtCost(*in.Cost.TotalCostUSD)+reset)
	}

	// Duration
	if in.Cost.TotalDurationMS != nil && *in.Cost.TotalDurationMS > 0 {
		out = append(out, cGray+gTime+" "+fmtDuration(*in.Cost.TotalDurationMS)+reset)
	}

	// Rate limits
	var rl []string
	if p := in.RateLimits.FiveHour.UsedPercentage; p != nil {
		rl = append(rl, rateColored("5h", *p))
	}
	if p := in.RateLimits.SevenDay.UsedPercentage; p != nil {
		rl = append(rl, rateColored("7d", *p))
	}
	if len(rl) > 0 {
		out = append(out, cGray+gRate+reset+" "+strings.Join(rl, " "))
	}

	// Effort / thinking
	if level := in.Effort.Level; level != "" {
		out = append(out, cPurple+gThink+" "+level+reset)
	} else if in.Thinking.Enabled {
		out = append(out, cPurple+gThink+" on"+reset)
	}

	// Worktree (not the same as git_worktree branch)
	if wt := in.Worktree.Name; wt != "" {
		out = append(out, cCyan+gWT+" "+wt+reset)
	}

	// Agent
	if agent := in.Agent.Name; agent != "" {
		out = append(out, cCyan+gAgent+" "+agent+reset)
	}

	// Permission mode (auto-appears when Anthropic exposes the field)
	if pm := in.PermissionMode; pm != "" {
		out = append(out, cCyan+"mode: "+pm+reset)
	}

	// Vim mode
	if v := in.Vim.Mode; v != "" {
		out = append(out, cYellow+gVim+" "+v+reset)
	}

	// Output style (only if non-default)
	if s := in.OutputStyle.Name; s != "" && s != "default" {
		out = append(out, cGray+"style: "+s+reset)
	}

	return out
}

// --- Helpers ---

func firstNonEmpty(vals ...string) string {
	for _, v := range vals {
		if v != "" {
			return v
		}
	}
	return ""
}

// dirBudget is the target max display width for the directory segment.
const dirBudget = 32

// displayDir shortens the path to fit dirBudget while always preserving the
// current directory name. Degradation order:
//  1. full path with ~ for home          ~/GolandProjects/andpad-vanguard-backend
//  2. abbreviate each parent to 1 char    ~/G/andpad-vanguard-backend
//  3. drop leftmost parents, prefix ".."  ..a/go/services/knowledge-subscriber
//  4. last resort: truncate the leaf      ..knowledge-subscriber-with-a-long-na…
// Hidden dirs keep the dot plus first char (.config -> .c).
func displayDir(p string) string {
	home, _ := os.UserHomeDir()
	underHome := home != "" && strings.HasPrefix(p, home)
	if underHome {
		p = strings.TrimPrefix(p, home)
	}

	var comps []string
	for _, s := range strings.Split(p, "/") {
		if s != "" {
			comps = append(comps, s)
		}
	}

	prefix := "/"
	if underHome {
		prefix = "~/"
	}
	if len(comps) == 0 {
		return strings.TrimSuffix(prefix, "/") // bare "~" or "/"
	}

	leaf := comps[len(comps)-1]
	parents := comps[:len(comps)-1]

	// Step 1: full path.
	full := prefix + strings.Join(comps, "/")
	if width(full) <= dirBudget {
		return full
	}

	// Step 2: abbreviate each parent to its first char.
	abbr := make([]string, len(parents))
	for i, s := range parents {
		abbr[i] = firstChar(s)
	}
	cand := prefix + strings.Join(append(abbr, leaf), "/")
	if width(cand) <= dirBudget {
		return cand
	}

	// Step 3: drop leftmost abbreviated parents until it fits, prefix "..".
	for n := len(abbr); n > 0; n-- {
		kept := append([]string{}, abbr[len(abbr)-n:]...)
		cand := ".." + strings.Join(append(kept, leaf), "/")
		if width(cand) <= dirBudget {
			return cand
		}
	}

	// Step 4: the leaf alone is over budget — truncate it.
	return ".." + truncate(leaf, dirBudget-2)
}

// width counts display columns (runes), close enough for path text.
func width(s string) int { return len([]rune(s)) }

// firstChar returns the first rune of a path segment, keeping the leading dot
// for hidden dirs (.config -> .c).
func firstChar(s string) string {
	r := []rune(s)
	if len(r) == 0 {
		return s
	}
	if r[0] == '.' && len(r) > 1 {
		return string(r[:2])
	}
	return string(r[:1])
}

func truncate(s string, max int) string {
	r := []rune(s)
	if len(r) <= max {
		return s
	}
	return string(r[:max-1]) + "…"
}

func fmtTokens(n int) string {
	switch {
	case n >= 1_000_000:
		return strings.TrimSuffix(fmt.Sprintf("%.1fM", float64(n)/1_000_000), ".0M") + ifSuffix(n, 1_000_000, "M")
	case n >= 1_000:
		return strings.TrimSuffix(fmt.Sprintf("%.1fk", float64(n)/1_000), ".0k") + ifSuffix(n, 1_000, "k")
	default:
		return fmt.Sprintf("%d", n)
	}
}

// ifSuffix is a tiny shim so trimming .0 doesn't lose the unit when value is exactly N.0
// (e.g. 1000 -> "1k" not "1"). Implementation detail of fmtTokens.
func ifSuffix(n, scale int, unit string) string {
	if n%scale == 0 {
		return unit
	}
	return ""
}

func fmtCost(usd float64) string {
	if usd < 0.01 {
		return "<$0.01"
	}
	return fmt.Sprintf("$%.2f", usd)
}

func fmtDuration(ms int) string {
	s := ms / 1000
	switch {
	case s < 60:
		return fmt.Sprintf("%ds", s)
	case s < 3600:
		return fmt.Sprintf("%dm", s/60)
	default:
		return fmt.Sprintf("%dh%dm", s/3600, (s%3600)/60)
	}
}

func rateColored(label string, pct float64) string {
	p := int(pct + 0.5)
	c := cGray
	if p >= 70 {
		c = cAmber
	}
	return fmt.Sprintf("%s%s:%d%%%s", c, label, p, reset)
}

// --- Git branch with 3s cache ---

func cacheDir() string {
	uid := "0"
	if u, err := user.Current(); err == nil {
		uid = u.Uid
	}
	d := filepath.Join(os.TempDir(), "claude-statusline-"+uid)
	_ = os.MkdirAll(d, 0o755)
	return d
}

func cacheGet(key string, ttl time.Duration) (string, bool) {
	p := filepath.Join(cacheDir(), key)
	st, err := os.Stat(p)
	if err != nil || time.Since(st.ModTime()) > ttl {
		return "", false
	}
	b, err := os.ReadFile(p)
	if err != nil {
		return "", false
	}
	return string(b), true
}

func cachePut(key, val string) {
	_ = os.WriteFile(filepath.Join(cacheDir(), key), []byte(val), 0o644)
}

func gitBranch(dir, override string) string {
	if override != "" {
		return override
	}
	if dir == "" {
		return ""
	}

	h := sha1.Sum([]byte(dir))
	key := "git-" + hex.EncodeToString(h[:])
	if v, ok := cacheGet(key, 3*time.Second); ok {
		return v
	}

	cmd := exec.Command("git", "-C", dir, "symbolic-ref", "--short", "HEAD")
	cmd.Env = append(os.Environ(), "GIT_OPTIONAL_LOCKS=0")
	out, err := cmd.Output()
	if err != nil {
		// Fall back to short SHA when detached.
		cmd = exec.Command("git", "-C", dir, "rev-parse", "--short", "HEAD")
		cmd.Env = append(os.Environ(), "GIT_OPTIONAL_LOCKS=0")
		out, err = cmd.Output()
		if err != nil {
			cachePut(key, "")
			return ""
		}
	}
	branch := strings.TrimSpace(string(out))
	cachePut(key, branch)
	return branch
}
