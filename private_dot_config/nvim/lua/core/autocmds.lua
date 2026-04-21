-- Automatically save buffers when text is changed or focus is lost
vim.api.nvim_create_autocmd({ 'FocusLost', 'BufLeave' }, {
    group = vim.api.nvim_create_augroup('AutoSave', { clear = true }),
    callback = function()
        -- Only save if the buffer is a normal file and has been modified
        if vim.bo.modified and vim.bo.buftype == '' and vim.fn.expand('%') ~= '' then
            vim.cmd('silent! wall')
        end
    end,
})

local fmt_group = vim.api.nvim_create_augroup('LspFormatting', { clear = true })

vim.api.nvim_create_autocmd('BufWritePre', {
    group = fmt_group,
    callback = function()
        local bufnr = vim.api.nvim_get_current_buf()
        local ft = vim.bo[bufnr].filetype

        -- 1. Check if any active LSP supports formatting for this buffer
        local clients = vim.lsp.get_clients({
            bufnr = bufnr,
            method = "textDocument/formatting"
        })

        -- If no formatting-capable LSP is found, exit early
        if #clients == 0 then
            return
        end

        -- 2. Special Handling: Go & Python (Organize Imports)
        if ft == 'go' or ft == 'python' then
            pcall(vim.lsp.buf.code_action, {
                context = {
                    only = { 'source.organizeImports' },
                    diagnostics = {},
                },
                apply = true,
            })
        end

        -- 3. Now it is safe to format because we know a client exists
        vim.lsp.buf.format({ bufnr = bufnr, async = false })
    end,
})
-- Briefly highlight yanked text
vim.api.nvim_create_autocmd('TextYankPost', {
    callback = function()
        vim.hl.on_yank()
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "checkhealth",
    callback = function()
        vim.keymap.set("n", "q", "<cmd>bd!<CR>", { buffer = true, silent = true })
    end,
})

-- Fix bufferline when restoring a session (Native implementation)
vim.api.nvim_create_autocmd({ 'BufAdd', 'BufDelete' }, {
    callback = function()
        vim.schedule(function()
            pcall(function()
                if vim.api.nvim_get_commands({}).BufferLineCycleNext then
                    vim.cmd('redrawtabline')
                end
            end)
        end)
    end,
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { os.getenv("HOME") .. "/.local/share/chezmoi/*" },
    callback = function(ev)
        local bufnr = ev.buf
        local edit_watch = function()
            require("chezmoi.commands.__edit").watch(bufnr)
        end
        vim.schedule(edit_watch)
    end,
})
