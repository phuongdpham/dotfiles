return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
        dependencies = {
            "nvim-treesitter/nvim-treesitter-textobjects",
        },
		opts = {
			ensure_installed = {
				"astro",
				"cmake",
				"cpp",
				"css",
				"fish",
				"gitignore",
				"go",
				"graphql",
				"http",
				"java",
				"php",
				"rust",
                "python",
				"scss",
				"sql",
				"svelte",
			},
            sync_install = false,
            auto_install = true,
            highlight = { enable = true },
            indent = { enable = true },

			-- matchup = {
			-- 	enable = true,
			-- },

            textobjects = {
                select = {
                  enable = true,
                  lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
                  keymaps = {
                    -- You can use the capture groups defined in textobjects.scm
                    ["af"] = "@function.outer", -- Select around function
                    ["if"] = "@function.inner", -- Select inner function
                    ["ac"] = "@class.outer",    -- Select around class
                    ["ic"] = "@class.inner",    -- Select inner class
                    ["aa"] = "@parameter.outer", -- Select around argument
                    ["ia"] = "@parameter.inner", -- Select inner argument
                  },
                },
                move = {
                  enable = true,
                  set_jumps = true, -- whether to set jumps in the jumplist
                  goto_next_start = {
                    ["]m"] = "@function.outer",
                    ["]]"] = "@class.outer",
                  },
                  goto_previous_start = {
                    ["[m"] = "@function.outer",
                    ["[["] = "@class.outer",
                  },
                },
              },
		},
		config = function(_, opts)
			local TS = require("nvim-treesitter")
			TS.setup(opts)

			-- MDX
			vim.filetype.add({
				extension = {
					mdx = "mdx",
				},
			})

            vim.treesitter.language.register("markdown", "mdx")

            -- ------------------------------------------------------------------
            -- KEYBINDINGS FOR THE NEW BUILT-IN PLAYGROUND
            -- ------------------------------------------------------------------
            local keymap = vim.keymap.set

            -- Open the full syntax tree (Replacement for :TSPlaygroundToggle)
            keymap("n", "<leader>it", ":InspectTree<CR>", { desc = "Inspect Tree (Playground)" })

            -- Show highlight groups under cursor (Replacement for :TSHighlightCapturesUnderCursor)
            keymap("n", "<leader>ih", ":Inspect<CR>", { desc = "Inspect Highlights" })

            -- Live Edit Treesitter Queries (Very useful for debugging textobjects)
            keymap("n", "<leader>iq", ":EditQuery<CR>", { desc = "Edit Treesitter Query" })
        end,
	},
}
