BIN := $(HOME)/.claude/statusline

build:
	go build -ldflags="-s -w" -o $(BIN) ./...

run:
	@echo '{"cwd":"$(PWD)","model":{"display_name":"Claude Opus 4.7"},"context_window":{"used_percentage":42,"total_input_tokens":80000,"total_output_tokens":2000,"context_window_size":200000},"cost":{"total_cost_usd":1.23,"total_duration_ms":900000},"effort":{"level":"high"},"rate_limits":{"five_hour":{"used_percentage":15},"seven_day":{"used_percentage":40}}}' | $(BIN)

bench:
	@TEST='{"cwd":"$(HOME)","model":{"display_name":"Claude Opus 4.7"},"context_window":{"used_percentage":20,"total_input_tokens":10000,"context_window_size":200000},"cost":{"total_cost_usd":0.5,"total_duration_ms":60000}}'; \
	echo "100 runs:"; \
	time (for i in $$(seq 1 100); do echo "$$TEST" | $(BIN) >/dev/null; done)

clean:
	rm -f $(BIN)

.PHONY: build run bench clean
