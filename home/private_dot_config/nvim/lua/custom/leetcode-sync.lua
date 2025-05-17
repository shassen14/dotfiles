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
  verbose = true,
  flat_leetcode_nvim_structure = true,
  debug_mode = false,
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

-- Extract problem info (This function remains the same as the previous "sync on any save" version)
local function extract_problem_info(current_file_path, lines)
  dbg_print("extract_problem_info: Starting for file:", current_file_path)
  local info = {
    id = nil, name = nil, title_slug = nil, difficulty = nil,
    accepted_marker_found = false, 
    description = {}, solution_code = {},
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

  for i, line in ipairs(lines) do
    local lcpr_key, lcpr_val = line:match("^%s*--%s*@lcpr%s+([^=]+)=(.*)")
    if not lcpr_key then lcpr_key, lcpr_val = line:match("^%s*//%s*@lcpr%s+([^=]+)=(.*)") end
    if not lcpr_key then lcpr_key, lcpr_val = line:match("^%s*#%s*@lcpr%s+([^=]+)=(.*)") end

    if lcpr_key and lcpr_val then
      lcpr_key, lcpr_val = lcpr_key:gsub("%s*$", ""), lcpr_val:gsub("%s*$", "")
      dbg_print("extract_problem_info: Found @lcpr:", lcpr_key, "=", lcpr_val)
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
        dbg_print("extract_problem_info: Fallback name extraction - ID:", info.id, "Name:", info.name)
      end
    end

    if not info.accepted_marker_found then
      if line:match("^%s*--%s*Runtime:") or line:match("^%s*//%s*Runtime:") or line:match("^%s*#%s*Runtime:") then
        info.accepted_marker_found = true
        dbg_print("extract_problem_info: Found 'Runtime:' on line #", i, " - (marker for acceptance found).")
      end
    end

    if line:match("@lcpr desc=start") then in_description = true; goto continue_loop end
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
  
  if not info.accepted_marker_found then
      dbg_print("extract_problem_info: Did NOT find any 'Runtime:' indicating line in the entire file.")
  end

  if not info.id then
    notify("Could not extract problem ID. Skipping sync.", vim.log.levels.WARN)
    dbg_print("extract_problem_info: FAIL - No ID"); return nil
  end
  if not info.name then
    info.name = info.title_slug or info.original_filename_slug or ("Problem " .. info.id)
    if info.name == ("Problem " .. info.id) then notify("Could not extract problem name/title. Using generic.", vim.log.levels.WARN) end
    dbg_print("extract_problem_info: Final name used:", info.name)
  end
  if not info.title_slug then
    info.title_slug = info.original_filename_slug or info.name:lower():gsub("[^%w%s%-]", ""):gsub("%s+", "-"):gsub("-%-", "-")
    dbg_print("extract_problem_info: Final title_slug used:", info.title_slug)
  end

  if not info.difficulty then
    notify("Problem difficulty not found in @lcpr metadata. README will not have difficulty badge.", vim.log.levels.WARN)
  end
  dbg_print("extract_problem_info: Success (Proceeding with sync). ID:", info.id, "Name:", info.name, "Slug:", info.title_slug)
  return info
end


-- Get difficulty badge HTML
local function get_difficulty_badge(difficulty)
  if not difficulty or difficulty == "" then return "" end
  local color
  if difficulty:lower() == "easy" then color = "brightgreen"
  elseif difficulty:lower() == "medium" then color = "orange"
  elseif difficulty:lower() == "hard" then color = "red"
  else dbg_print("get_difficulty_badge: Unknown difficulty:", difficulty); return ""
  end
  return string.format("<img src='https://img.shields.io/badge/Difficulty-%s-%s' alt='Difficulty: %s' />",
                       difficulty, color, difficulty)
end

-- Main sync function
function M.do_sync_current_buffer(triggered_by_autocmd)
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

  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local problem_info = extract_problem_info(current_file_path, lines)

  if not problem_info then
    dbg_print("do_sync_current_buffer: problem_info extraction failed (e.g. no ID).")
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

  -- ******** CHANGED FILE COPY METHOD ********
  local err, success_or_errmsg = pcall(vim.uv.fs_copyfile, current_file_path, dest_file_path, 0)
  if not err or not success_or_errmsg then -- pcall returns false on error; fs_copyfile returns nil on success, error string on failure
    -- Check if fs_copyfile returned an error string (meaning pcall succeeded but fs_copyfile itself failed)
    if success_or_errmsg then -- This means fs_copyfile returned an error message
        notify("Failed to copy solution file to " .. dest_file_path .. ". Error: " .. tostring(success_or_errmsg), vim.log.levels.ERROR)
        dbg_print("do_sync_current_buffer: vim.uv.fs_copyfile FAILED from", current_file_path, "to", dest_file_path, "Error:", tostring(success_or_errmsg))
        return
    end
    -- If pcall itself failed (not err is true), or fs_copyfile returned nil (success) but err was false (should not happen)
    if not err then
        notify("Error during pcall for file copy: " .. tostring(success_or_errmsg), vim.log.levels.ERROR)
        dbg_print("do_sync_current_buffer: pcall(vim.uv.fs_copyfile) FAILED. Error:", tostring(success_or_errmsg))
        return
    end
  end
  -- If we reach here, fs_copyfile succeeded (returned nil) and pcall also succeeded.
  notify("Solution file copied to " .. dest_file_path, vim.log.levels.INFO)
  dbg_print("do_sync_current_buffer: vim.uv.fs_copyfile SUCCESS to", dest_file_path)
  -- ******************************************


  local problem_url = "https://leetcode.com/problems/" .. problem_info.title_slug .. "/"
  local readme_content = {
    "<h2><a href=\"" .. problem_url .. "\">" .. problem_info.id .. ". " .. problem_info.name .. "</a></h2>",
  }
  local badge = get_difficulty_badge(problem_info.difficulty)
  if badge ~= "" then table.insert(readme_content, badge) end
  table.insert(readme_content, "<hr>")
  table.insert(readme_content, "")

  if #problem_info.description > 0 then
    vim.list_extend(readme_content, problem_info.description)
    table.insert(readme_content, "")
  else
    notify("Problem description not found (missing @lcpr desc=start/end). README will be minimal.", vim.log.levels.WARN)
  end

  if #problem_info.solution_code > 0 then
    table.insert(readme_content, config.readme_solution_header .. " (`" .. problem_info.language_ext .. "`)")
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

-- Setup function (This function remains the same as the previous version)
function M.setup(user_config)
  config = vim.tbl_deep_extend("force", config, user_config or {})
  dbg_print("M.setup: Config loaded. Debug mode:", config.debug_mode)
  dbg_print("M.setup: Leetcode dir:", config.leetcode_nvim_solution_dir)
  dbg_print("M.setup: Github repo:", config.github_repo_path)
  dbg_print("M.setup: Flat structure:", config.flat_leetcode_nvim_structure)

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
        M.do_sync_current_buffer(true)
      else
        dbg_print("Autocmd: Conditions NOT met. File:", args.file, "Trigger check (flat):", should_trigger)
      end
    end,
  })

  vim.api.nvim_create_user_command("LeetCodeSyncNow", function()
    M.do_sync_current_buffer(false)
  end, {
    desc = "Manually sync current LeetCode solution to GitHub repo",
  })
  dbg_print("M.setup: User command LeetCodeSyncNow created.")

  notify("LeetCode GitHub Sync enabled.", vim.log.levels.INFO)
  if config.verbose or config.debug_mode then
    notify("LeetCode.nvim dir: " .. config.leetcode_nvim_solution_dir .. (config.flat_leetcode_nvim_structure and " (flat)" or " (nested)"), vim.log.levels.DEBUG)
    notify("Syncing to GitHub repo: " .. config.github_repo_path, vim.log.levels.DEBUG)
    notify("Using autocmd pattern: " .. autocmd_pattern, vim.log.levels.DEBUG)
  end
end


return M