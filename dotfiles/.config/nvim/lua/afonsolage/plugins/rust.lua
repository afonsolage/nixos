local setup_rust_dap = function()
	local codelldb_path = ""
	local liblldb_path = ""
	if vim.loop.os_uname().version:find("NixOS") then
		-- On this NixOS there I created a link from pkg code-lldb to ~/.vscode
		local extension_path = vim.env.HOME .. "/.vscode/extensions/vadimcn.vscode-lldb/"

		codelldb_path = extension_path .. "adapter/codelldb"
		liblldb_path = extension_path .. "lldb/lib/liblldb"
	else
		local ok, mason_registry = pcall(require, "mason-registry")
		local adapter
		if ok then
			-- rust tools configuration for debugging support
			local codelldb = mason_registry.get_package("codelldb")
			local extension_path = codelldb:get_install_path() .. "/extension/"
			codelldb_path = extension_path .. "adapter/codelldb"

			if vim.loop.os_uname().sysname:find("Windows") then
				liblldb_path = extension_path .. "lldb\\bin\\liblldb.dll"
			elseif vim.fn.has("mac") == 1 then
				liblldb_path = extension_path .. "lldb/lib/liblldb.dylib"
			else
				liblldb_path = extension_path .. "lldb/lib/liblldb.so"
			end
		end
	end
	adapter = require("rustaceanvim.config").get_codelldb_adapter(codelldb_path, liblldb_path)
	return adapter
end

return {
	{
		"saecki/crates.nvim",
		event = { "BufRead Cargo.toml" },
		config = function()
			require("crates").setup()
		end,
	},
	{
		"ron-rs/ron.vim",
	},
	{
		"mrcjkb/rustaceanvim",
		version = "^6", -- Recommended
		lazy = false, -- This plugin is already lazy
		ft = { "rust" },
		config = function()
			vim.g.rustaceanvim = {
				server = {
					on_attach = function(client, bufrn)
						local opts = { buffer = bufrn, remap = false }

						vim.lsp.inlay_hint.enable(true)

						vim.keymap.set("n", "K", function()
							vim.cmd.RustLsp({ "hover", "actions" })
						end, opts)

						vim.keymap.set("v", "<c-k>", function()
							vim.cmd.RustLsp({ "hover", "range" })
						end, opts)

						vim.keymap.set("n", "<c-J>", function()
							vim.cmd.RustLsp("joinLines")
						end, opts)

						-- vim.keymap.set("v", "K",
						-- function()
						--         vim.cmd.RustLsp { "moveItem", "up" }
						-- end, opts)
						--
						-- vim.keymap.set("v", "J",
						-- function()
						--         vim.cmd.RustLsp { "moveItem", "down" }
						-- end, opts)

						vim.keymap.set({ "n", "v" }, "<leader>vca", function()
							--vim.lsp.buf.code_action()
							vim.cmd.RustLsp("codeAction")
						end, opts)
						vim.keymap.set("n", "<leader>h", function()
							local enabled = vim.lsp.inlay_hint.is_enabled()
							vim.lsp.inlay_hint.enable(not enabled, opts)
						end, opts)
						vim.keymap.set("n", "<leader>vee", function()
							vim.cmd.RustLsp({ "explainError", "current" })
						end, opts)
						vim.keymap.set("n", "gd", function()
							vim.lsp.buf.definition()
						end, opts)
						vim.keymap.set("n", "<leader>vws", function()
							vim.lsp.buf.workspace_symbol()
						end, opts)

						vim.keymap.set("n", "<leader>vd", function()
							vim.diagnostic.open_float()
						end, opts)
						vim.keymap.set("n", "[d", function()
							vim.diagnostic.goto_next()
						end, opts)
						vim.keymap.set("n", "]d", function()
							vim.diagnostic.goto_prev()
						end, opts)
						vim.keymap.set("n", "<leader>rd", function()
							vim.cmd.RustLsp("renderDiagnostic")
						end, opts)

						vim.keymap.set("n", "<leader>vrr", function()
							vim.lsp.buf.references()
						end, opts)
						vim.keymap.set("n", "<leader>vrn", function()
							vim.lsp.buf.rename()
						end, opts)

						vim.keymap.set("i", "<C-h>", function()
							vim.lsp.buf.signature_help()
						end, opts)
						vim.keymap.set("n", "<leader>vme", function()
							vim.cnd.RustLsp("expandMacro")
						end, opts)
						vim.keymap.set("n", "<leader>tt", function()
							vim.cmd.RustLsp("testables")
						end, opts)

						vim.keymap.set("n", "<leader>dd", function()
							vim.cmd.RustLsp("debuggables")
						end, opts)

						vim.keymap.set("n", "<leader>rr", function()
							vim.cmd.RustLsp("runnables")
						end, opts)

						vim.api.nvim_create_autocmd("BufWritePre", {
							buffer = bufrn,
							callback = function()
								vim.lsp.buf.format({ async = false })
							end,
						})
					end,
				},
				settings = {
					["rust-analyzer"] = {
						cargo = {
							loadOutDirsFromCheck = true,
							runBuildScripts = true,
						},
						checkOnSave = {
							allFeatures = true,
							command = "clippy",
							extraArgs = { "--no-deps" },
						},
						procMacro = {
							enable = true,
							ignored = {
								["async-trait"] = { "async_trait" },
								["napi-derive"] = { "napi" },
								["async-recursion"] = { "async_recursion" },
							},
						},
						inlayHints = {
							enable = true,
							showParameterNames = true,
						},
					},
				},
				dap = {
					load_rust_types = true,
					adapter = setup_rust_dap(),
				},
				tools = {
					test_executor = "background",
					code_actions = {
						ui_select_fallback = true,
					},
				},
			}
		end,
	},
}
