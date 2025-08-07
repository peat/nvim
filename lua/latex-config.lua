-- Add this to your ~/.config/nvim/init.lua or create a separate file like ~/.config/nvim/lua/latex-config.lua

-- Enhanced LaTeX build function
local function build_latex()
  local file = vim.fn.expand("%:p")
  local dir = vim.fn.expand("%:p:h")
  local name = vim.fn.expand("%:t:r")
  
  print("Building LaTeX: " .. name)
  
  -- Check if we're in a workshop directory (use Makefile)
  if string.match(dir, "workshops/foundations") then
    print("Detected Foundations workshop - using Makefile")
    vim.cmd("silent !cd " .. dir .. "/../../ && make foundations")
  elseif string.match(dir, "workshops/momentum") then
    print("Detected Momentum workshop - using Makefile")
    vim.cmd("silent !cd " .. dir .. "/../../ && make momentum")
  elseif string.match(dir, "workshops/scaling") then
    print("Detected Scaling workshop - using Makefile")
    vim.cmd("silent !cd " .. dir .. "/../../ && make scaling")
  else
    -- Standard pdflatex build for standalone files
    print("Using standard pdflatex build")
    vim.cmd("silent !cd " .. dir .. " && pdflatex -interaction=nonstopmode " .. name .. ".tex")
  end
  
  -- Wait a moment for build to complete
  vim.cmd("sleep 1")
  
  -- Check for PDF and open in Skim
  -- For Makefile builds, PDFs go to output/pdf/
  local pdf_file_makefile = dir .. "/../../output/pdf/" .. name .. ".pdf"
  local pdf_file_local = dir .. "/" .. name .. ".pdf"
  
  if vim.fn.filereadable(pdf_file_makefile) == 1 then
    vim.cmd("silent !open -a Skim '" .. pdf_file_makefile .. "'")
    print("✓ Opened PDF in Skim: " .. pdf_file_makefile)
  elseif vim.fn.filereadable(pdf_file_local) == 1 then
    vim.cmd("silent !open -a Skim '" .. pdf_file_local .. "'")
    print("✓ Opened PDF in Skim: " .. pdf_file_local)
  else
    print("⚠ PDF not found - check build errors")
  end
end

-- Check build status function (optional - shows any errors)
local function check_build_status()
  local file = vim.fn.expand("%:t:r")
  local dir = vim.fn.expand("%:p:h")
  
  -- Check for common LaTeX log files
  local log_file = dir .. "/" .. file .. ".log"
  if vim.fn.filereadable(log_file) == 1 then
    -- Quick error check
    local errors = vim.fn.system("grep -i 'error\\|fatal' " .. log_file)
    if errors ~= "" then
      print("⚠ Build errors detected - check " .. log_file)
    end
  end
end

-- Autocmd for LaTeX files - build on save
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.tex",
  callback = function()
    build_latex()
    -- Optional: check for errors after build
    vim.defer_fn(check_build_status, 2000) -- Check after 2 seconds
  end,
  desc = "Build LaTeX with smart detection on save"
})

-- LaTeX-specific settings and keymaps
vim.api.nvim_create_autocmd("FileType", {
  pattern = "tex",
  callback = function()
    print("✓ LaTeX configuration loaded!")
    print("Keymaps: <leader>lb (build), <leader>lv (view), <leader>lc (clean), <leader>lw (word count), <leader>ll (log)")
    -- Better editing for LaTeX
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_us"
    vim.opt_local.textwidth = 80
    
    -- Useful keymaps for LaTeX workflow
    local opts = { buffer = true, silent = true }
    
    -- Manual build (if you want to build without saving)
    vim.keymap.set("n", "<leader>lb", build_latex, vim.tbl_extend("force", opts, { desc = "Build LaTeX" }))
    
    -- Open PDF in Skim
    vim.keymap.set("n", "<leader>lv", function()
      local dir = vim.fn.expand("%:p:h")
      local name = vim.fn.expand("%:t:r")
      local pdf_file_makefile = dir .. "/../../output/pdf/" .. name .. ".pdf"
      local pdf_file_local = dir .. "/" .. name .. ".pdf"
      
      if vim.fn.filereadable(pdf_file_makefile) == 1 then
        vim.cmd("silent !open -a Skim '" .. pdf_file_makefile .. "'")
      elseif vim.fn.filereadable(pdf_file_local) == 1 then
        vim.cmd("silent !open -a Skim '" .. pdf_file_local .. "'")
      else
        print("PDF not found")
      end
    end, vim.tbl_extend("force", opts, { desc = "View PDF in Skim" }))
    
    -- Clean build files
    vim.keymap.set("n", "<leader>lc", function()
      local dir = vim.fn.expand("%:p:h")
      if string.match(dir, "workshops/") then
        vim.cmd("!cd " .. dir .. "/../../ && make clean")
      else
        vim.cmd("!cd " .. dir .. " && rm -f *.aux *.log *.bbl *.blg *.toc *.out *.fls *.fdb_latexmk *.glo *.gls *.glg")
      end
      print("Cleaned build files")
    end, vim.tbl_extend("force", opts, { desc = "Clean LaTeX build files" }))
    
    -- Quick word count (useful for handbooks)
    vim.keymap.set("n", "<leader>lw", function()
      local words = vim.fn.system("texcount -1 -sum " .. vim.fn.expand("%"))
      print("Word count: " .. vim.trim(words))
    end, vim.tbl_extend("force", opts, { desc = "LaTeX word count" }))
    
    -- Show LaTeX log file (for debugging)
    vim.keymap.set("n", "<leader>ll", function()
      local log_file = vim.fn.expand("%:r") .. ".log"
      if vim.fn.filereadable(log_file) == 1 then
        vim.cmd("split " .. log_file)
      else
        print("No log file found")
      end
    end, vim.tbl_extend("force", opts, { desc = "Show LaTeX log" }))
  end,
  desc = "LaTeX file settings and keymaps"
})

-- Quick LaTeX snippets (optional but handy)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "tex",
  callback = function()
    local opts = { buffer = true, silent = true }
    
    -- Quick \begin{} \end{} block
    vim.keymap.set("i", "\\begin", function()
      local env = vim.fn.input("Environment: ")
      if env ~= "" then
        return "\\begin{" .. env .. "}\n\n\\end{" .. env .. "}"
      else
        return "\\begin{}"
      end
    end, vim.tbl_extend("force", opts, { expr = true, desc = "LaTeX begin/end block" }))
    
    -- Quick section
    vim.keymap.set("i", "\\sec", "\\section{}<Esc>i", opts)
    vim.keymap.set("i", "\\sub", "\\subsection{}<Esc>i", opts)
  end,
})

-- Status line indicator for LaTeX mode (optional)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "tex",
  callback = function()
    -- Add LaTeX indicator to status line if you want
    vim.b.latex_mode = true
  end,
})

