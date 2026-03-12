-- ~/.config/nvim/lua/custom/leetcode-sync.lua

local M = {}

-- Default configuration
local config = {
  leetcode_nvim_solution_dir = vim.fn.stdpath("data") .. "/leetcode", -- e.g., vim.fn.stdpath("data") .. "/leetcode"
  github_repo_path = vim.fn.expand("~/Documents/learning/lc_direct"),           -- e.g., vim.fn.expand("~/path/to/your/leetcode-repo")
  commit_prefix = "feat(leetcode):",
  auto_push = true,
  readme_solution_header = "## Solution",
  languages_pattern = "{cpp,py,java,js,ts,go,rs,lua,kt,swift,cs,rb,php,scala,dart}",
  verbose = false,
  flat_leetcode_nvim_structure = true,
  debug_mode = false,
  skip_acceptance_check = false, -- New: Set to true to always sync on save regardless of acceptance
}

-- Debug print helper
local function dbg_print(...)
  if config.debug_mode then
    local parts = {}
    for i = 1, select("#", ...) do parts[i] = tostring(select(i, ...)) end
    local msg = "[LC SYNC DEBUG] " .. table.concat(parts, " ")
    vim.notify(msg, vim.log.levels.INFO)
    print(msg)
  end
end

-- Notification helper
local function notify(msg, level, title)
  if not config.verbose and level ~= vim.log.levels.ERROR and level ~= vim.log.levels.WARN then
    if not config.debug_mode then return end
  end
  vim.notify(msg, level or vim.log.levels.INFO, { title = title or "LeetCode Sync" })
end

-- Async command runner
local function run_async_cmd(cmd_parts, cwd, on_exit_callback)
  vim.fn.jobstart(cmd_parts, {
    cwd = cwd,
    on_exit = function(_, exit_code, _) if on_exit_callback then on_exit_callback(exit_code) end end,
    on_stderr = function(_, data, _)
      if data and #data > 0 and data[1] ~= "" then
        local err_msg = "Error running '" .. table.concat(cmd_parts, " ") .. "':\n" .. table.concat(data, "\n")
        notify(err_msg, vim.log.levels.ERROR); dbg_print("Async cmd error:", err_msg)
      end
    end,
    stdout_buffered = true, stderr_buffered = true,
  })
end

-- Helper to check current (UI) buffer for acceptance strings
local function check_current_buffer_for_acceptance_ui()
  dbg_print("check_current_buffer_for_acceptance_ui: Checking current visible buffer for acceptance strings.")
  local current_buf_lines = vim.api.nvim_buf_get_lines(0, 0, 100, false) -- Check first 100 lines of current buffer
  for i, line in ipairs(current_buf_lines) do
    if line:match("[Aa]ccepted") or line:match("[Rr]untime:") or line:match("Solution accepted") or line:match("Test Succeeded") or line:match("Success") then
      dbg_print("check_current_buffer_for_acceptance_ui: Found acceptance-like string on line", i, ":", line)
      return true
    end
  end
  dbg_print("check_current_buffer_for_acceptance_ui: No acceptance-like string found in current visible buffer's first 100 lines.")
  return false
end


-- Extract problem info
local function extract_problem_info(current_file_path, file_content_lines, check_ui_for_acceptance_flag)
  dbg_print("extract_problem_info: Starting for file:", current_file_path, "UI check requested:", check_ui_for_acceptance_flag)
  local info = {
    id = nil, name = nil, title_slug = nil, difficulty = nil,
    accepted_marker_found_in_file = false,
    accepted_via_ui_check = false,
    description = {}, description_markers_found = false,
    solution_code = {},
    language_ext = vim.fn.fnamemodify(current_file_path, ":e"),
    original_filename_slug = nil,
  }

  local filename_base = vim.fn.fnamemodify(current_file_path, ":t:r")
  local id_from_filename, slug_from_filename = filename_base:match("^(%d+)%.(.+)$")
  if id_from_filename then
    info.id = id_from_filename
    info.original_filename_slug = slug_from_filename
    dbg_print("extract_problem_info: From filename - ID:", info.id, "Slug:", info.original_filename_slug)
  else
    dbg_print("extract_problem_info: Could not parse ID/slug from filename:", filename_base)
  end

  local in_description, in_solution_code = false, false

  for i, line in ipairs(file_content_lines) do -- Iterate over lines from the actual file content
    local lcpr_key, lcpr_val = line:match("^%s*--%s*@lcpr%s+([^=]+)=(.*)")
    if not lcpr_key then lcpr_key, lcpr_val = line:match("^%s*//%s*@lcpr%s+([^=]+)=(.*)") end
    if not lcpr_key then lcpr_key, lcpr_val = line:match("^%s*#%s*@lcpr%s+([^=]+)=(.*)") end

    if lcpr_key and lcpr_val then
      lcpr_key, lcpr_val = lcpr_key:gsub("%s*$", ""), lcpr_val:gsub("%s*$", "")
      if lcpr_key == "id" then info.id = lcpr_val
      elseif lcpr_key == "name" then info.name = lcpr_val
      elseif lcpr_key == "title" then info.title_slug = lcpr_val
      elseif lcpr_key == "difficulty" then info.difficulty = lcpr_val
      end
    end

    if not info.name and i <= 15 then
      local num, tle = line:match("^%s*--%s*(%d+)%.%s+(.+)")
      if not num then num, tle = line:match("^%s*//%s*(%d+)%.%s+(.+)") end
      if not num then num, tle = line:match("^%s*#%s*(%d+)%.%s+(.+)") end
      if num and tle then
        if not info.id then info.id = num end
        info.name = tle:match("^(.-)%s*$")
      end
    end

    if not info.accepted_marker_found_in_file then
      if line:match("^%s*--%s*Runtime:") or line:match("^%s*//%s*Runtime:") or line:match("^%s*#%s*Runtime:") then
        info.accepted_marker_found_in_file = true
        dbg_print("extract_problem_info: Found 'Runtime:' in FILE on line #", i)
      end
    end
    
    if line:match("@lcpr desc=start") then in_description = true; info.description_markers_found = true; goto continue_loop end
    if line:match("@lcpr desc=end") then in_description = false; goto continue_loop end
    if in_description then table.insert(info.description, line) end

    if line:match("@lc code=start") then in_solution_code = true; goto continue_loop end
    if line:match("@lc code=end") then in_solution_code = false; goto continue_loop end
    if in_solution_code then
      if not line:match("@lcpr-template") and not line:match("Please remember to NOT include package statement") then
         table.insert(info.solution_code, line)
      end
    end
    ::continue_loop::
  end
  
  if not info.accepted_marker_found_in_file then dbg_print("extract_problem_info: Did NOT find 'Runtime:' line in FILE content.") end
  if not info.description_markers_found then dbg_print("extract_problem_info: Did NOT find @lcpr desc=start marker in FILE content.") end

  if check_ui_for_acceptance_flag then
    info.accepted_via_ui_check = check_current_buffer_for_acceptance_ui()
  end

  local should_proceed = false
  if config.skip_acceptance_check then
    should_proceed = true; dbg_print("extract_problem_info: Proceeding: skip_acceptance_check is true.")
  elseif info.accepted_marker_found_in_file then
    should_proceed = true; dbg_print("extract_problem_info: Proceeding: Marker found in FILE content.")
  elseif info.accepted_via_ui_check then
    should_proceed = true; dbg_print("extract_problem_info: Proceeding: Acceptance found via UI check.")
  end

  if not info.id then
    notify("Could not extract problem ID. Skipping sync.", vim.log.levels.WARN)
    dbg_print("extract_problem_info: FAIL - No ID"); return nil
  end
  if not info.name then
    info.name = info.title_slug or info.original_filename_slug or ("Problem " .. info.id)
    if info.name == ("Problem " .. info.id) then notify("Could not extract problem name/title. Using generic.", vim.log.levels.WARN) end
  end
  if not info.title_slug then
    info.title_slug = info.original_filename_slug or info.name:lower():gsub("[^%w%s%-]", ""):gsub("%s+", "-"):gsub("-%-", "-")
  end

  if not should_proceed then
    notify("Solution not determined as accepted. Skipping sync for " .. (info.name or "ID: "..info.id), vim.log.levels.INFO)
    dbg_print("extract_problem_info: FAIL - Not determined as accepted (file marker, UI check, or skip_acceptance_check).")
    return nil
  end

  if not info.difficulty then notify("Problem difficulty not found in @lcpr metadata.", vim.log.levels.WARN) end
  dbg_print("extract_problem_info: Success. ID:", info.id, "Name:", info.name, "Slug:", info.title_slug)
  return info
end

-- Get difficulty tag (LeetHub style)
local function get_difficulty_tag(difficulty)
  if not difficulty or difficulty == "" then return "" end
  return string.format("<h3>Difficulty: %s</h3>", difficulty)
end

-- Main sync function
function M.do_sync_current_buffer(triggered_by_autocmd)
  local is_manual_trigger = not triggered_by_autocmd
  if triggered_by_autocmd then
    dbg_print("do_sync_current_buffer: Auto-triggered by BufWritePost.")
  else
    dbg_print("do_sync_current_buffer: Manually triggered by :LeetCodeSyncNow.")
  end

  local current_file_path = vim.api.nvim_buf_get_name(0)
  if not current_file_path or current_file_path == "" then
    notify("No file path for current buffer. Ensure a LeetCode solution file is active.", vim.log.levels.WARN)
    dbg_print("do_sync_current_buffer: No file path available."); return
  end
  dbg_print("do_sync_current_buffer: Processing file:", current_file_path)

  -- Get the buffer number for the file path
  local file_bufnr = vim.fn.bufnr(current_file_path)
  if file_bufnr == -1 then
      notify("Could not find buffer for file: " .. current_file_path, vim.log.levels.ERROR)
      dbg_print("do_sync_current_buffer: Buffer not found for file path."); return
  end
  local file_content_lines = vim.api.nvim_buf_get_lines(file_bufnr, 0, -1, false)
  
  local problem_info = extract_problem_info(current_file_path, file_content_lines, is_manual_trigger)

  if not problem_info then
    dbg_print("do_sync_current_buffer: problem_info extraction failed or solution not determined as accepted.")
    return
  end

  local folder_name = problem_info.id .. "-" .. problem_info.title_slug
  local dest_dir_path = config.github_repo_path .. "/" .. folder_name
  local dest_solution_filename = problem_info.title_slug .. "." .. problem_info.language_ext
  local dest_file_path = dest_dir_path .. "/" .. dest_solution_filename
  local readme_path = dest_dir_path .. "/README.md"
  dbg_print("do_sync_current_buffer: Dest dir:", dest_dir_path, " Dest file:", dest_file_path, " README:", readme_path)

  if vim.fn.mkdir(dest_dir_path, "p") == -1 then
      notify("Failed to create directory " .. dest_dir_path, vim.log.levels.ERROR)
      dbg_print("do_sync_current_buffer: mkdir FAILED for", dest_dir_path); return
  end
  dbg_print("do_sync_current_buffer: mkdir success/exists for", dest_dir_path)

  local err, success_or_errmsg = pcall(vim.uv.fs_copyfile, current_file_path, dest_file_path, 0)
  if not err or not success_or_errmsg then
    if success_or_errmsg then
        notify("Failed to copy solution file to " .. dest_file_path .. ". Error: " .. tostring(success_or_errmsg), vim.log.levels.ERROR)
        dbg_print("do_sync_current_buffer: vim.uv.fs_copyfile FAILED from", current_file_path, "to", dest_file_path, "Error:", tostring(success_or_errmsg)); return
    end
    if not err then
        notify("Error during pcall for file copy: " .. tostring(success_or_errmsg), vim.log.levels.ERROR)
        dbg_print("do_sync_current_buffer: pcall(vim.uv.fs_copyfile) FAILED. Error:", tostring(success_or_errmsg)); return
    end
  end
  notify("Solution file copied to " .. dest_file_path, vim.log.levels.INFO)
  dbg_print("do_sync_current_buffer: vim.uv.fs_copyfile SUCCESS to", dest_file_path)

  local problem_url = "https://leetcode.com/problems/" .. problem_info.title_slug .. "/"
  local readme_content = {
    "<h2><a href=\"" .. problem_url .. "\">" .. problem_info.id .. ". " .. problem_info.name .. "</a></h2>",
  }
  local diff_tag = get_difficulty_tag(problem_info.difficulty)
  if diff_tag ~= "" then table.insert(readme_content, diff_tag) end
  table.insert(readme_content, "<hr>")
  table.insert(readme_content, "")

  if #problem_info.description > 0 then
    dbg_print("do_sync_current_buffer: Adding", #problem_info.description, "lines of description to README.")
    vim.list_extend(readme_content, problem_info.description)
    table.insert(readme_content, "") 
  else
    notify("Problem description not found in solution file (missing @lcpr desc=start/end content). README will be minimal.", vim.log.levels.WARN)
    dbg_print("do_sync_current_buffer: No description content found in problem_info.description.")
  end

  if #problem_info.solution_code > 0 then
    table.insert(readme_content, "---")
    table.insert(readme_content, "")
    table.insert(readme_content, config.readme_solution_header)
    table.insert(readme_content, "")
    table.insert(readme_content, "```" .. problem_info.language_ext)
    vim.list_extend(readme_content, problem_info.solution_code)
    table.insert(readme_content, "```")
  else
    notify("Solution code for README not found (missing @lc code=start/end).", vim.log.levels.WARN)
  end

  local readme_file = io.open(readme_path, "w")
  if readme_file then
    readme_file:write(table.concat(readme_content, "\n"))
    readme_file:close()
    notify("README.md created/updated at " .. readme_path, vim.log.levels.INFO)
    dbg_print("do_sync_current_buffer: README written successfully to", readme_path)
  else
    notify("Could not write README.md to " .. readme_path, vim.log.levels.ERROR)
    dbg_print("do_sync_current_buffer: FAILED to write README.md to", readme_path); return
  end

  local commit_message = config.commit_prefix .. " Add solution for " .. problem_info.id .. ". " .. problem_info.name
  dbg_print("do_sync_current_buffer: Git commit message:", commit_message)

  run_async_cmd({ "git", "add", dest_file_path, readme_path }, config.github_repo_path, function(add_exit_code)
    dbg_print("do_sync_current_buffer: Git add exited with code:", add_exit_code)
    if add_exit_code ~= 0 then
      notify("Failed to git add files for " .. problem_info.name, vim.log.levels.ERROR); return
    end
    dbg_print("Files added to git index for: " .. problem_info.name)

    run_async_cmd({ "git", "commit", "-m", commit_message }, config.github_repo_path, function(commit_exit_code)
      dbg_print("do_sync_current_buffer: Git commit exited with code:", commit_exit_code)
      if commit_exit_code == 0 then
        notify("Successfully committed: " .. problem_info.name, vim.log.levels.INFO)
        if config.auto_push then
          dbg_print("do_sync_current_buffer: Attempting git push...")
          run_async_cmd({ "git", "push" }, config.github_repo_path, function(push_exit_code)
            dbg_print("do_sync_current_buffer: Git push exited with code:", push_exit_code)
            if push_exit_code == 0 then
              notify("Successfully pushed: " .. problem_info.name, vim.log.levels.INFO)
            else
              notify("Failed to git push for " .. problem_info.name .. ". Push manually.", vim.log.levels.ERROR)
            end
          end)
        else
          dbg_print("do_sync_current_buffer: Auto push disabled.")
        end
      elseif commit_exit_code == 1 then
         notify("Commit skipped for " .. problem_info.name .. " (likely no changes).", vim.log.levels.WARN)
      else
        notify("Failed to git commit for " .. problem_info.name, vim.log.levels.ERROR)
      end
    end)
  end)
end

-- Setup function
function M.setup(user_config)
  config = vim.tbl_deep_extend("force", config, user_config or {})
  config.skip_acceptance_check = config.skip_acceptance_check or false 

  dbg_print("M.setup: Config loaded. Debug mode:", config.debug_mode, "Skip acceptance check:", config.skip_acceptance_check)
  dbg_print("M.setup: Leetcode dir:", config.leetcode_nvim_solution_dir)
  dbg_print("M.setup: Github repo:", config.github_repo_path)
  dbg_print("M.setup: Flat structure:", config.flat_leetcode_nvim_structure) -- Corrected typo from previous

  if not vim.fn.isdirectory(config.leetcode_nvim_solution_dir) then
    notify("LeetCode.nvim solution directory not found: " .. config.leetcode_nvim_solution_dir, vim.log.levels.ERROR); return
  end
  if not vim.fn.isdirectory(config.github_repo_path) or not vim.fn.isdirectory(config.github_repo_path .. "/.git") then
    notify("GitHub repository path is invalid or not a Git repo: " .. config.github_repo_path, vim.log.levels.ERROR); return
  end

  local autocmd_pattern
  if config.flat_leetcode_nvim_structure then
    autocmd_pattern = vim.fs.normalize(config.leetcode_nvim_solution_dir) .. "/*." .. config.languages_pattern
  else
    autocmd_pattern = vim.fs.normalize(config.leetcode_nvim_solution_dir) .. "/*/*/*." .. config.languages_pattern
  end
  dbg_print("M.setup: Autocmd pattern:", autocmd_pattern)

  vim.api.nvim_create_autocmd("BufWritePost", {
    group = vim.api.nvim_create_augroup("LeetCodeGithubSync", { clear = true }),
    pattern = autocmd_pattern,
    callback = function(args)
      dbg_print("BufWritePost Autocmd triggered for file:", args.file)
      local normalized_args_file_dir = vim.fs.normalize(vim.fn.fnamemodify(args.file, ":h"))
      local normalized_leetcode_dir = vim.fs.normalize(config.leetcode_nvim_solution_dir)
      dbg_print("Normalized args file dir:", normalized_args_file_dir, "Normalized leetcode dir:", normalized_leetcode_dir)
      
      local should_trigger = false
      if config.flat_leetcode_nvim_structure then
          should_trigger = (normalized_args_file_dir == normalized_leetcode_dir)
      else
          should_trigger = (args.file:find(normalized_leetcode_dir, 1, true) == 1)
      end

      if args.file and should_trigger then
        dbg_print("Autocmd: Conditions met, calling M.do_sync_current_buffer(true)")
        M.do_sync_current_buffer(true) -- Pass true (autocmd)
      else
        dbg_print("Autocmd: Conditions NOT met. File:", args.file, "Trigger check (flat):", should_trigger)
      end
    end,
  })

  vim.api.nvim_create_user_command("LeetCodeSyncNow", function()
    M.do_sync_current_buffer(false) -- Pass false (manual)
  end, {
    desc = "Manually sync current LeetCode solution to GitHub repo",
  })
  dbg_print("M.setup: User command LeetCodeSyncNow created.")

  dbg_print("M.setup: LeetCode GitHub Sync enabled. Dir:", config.leetcode_nvim_solution_dir, "Repo:", config.github_repo_path, "Pattern:", autocmd_pattern)
end

return M