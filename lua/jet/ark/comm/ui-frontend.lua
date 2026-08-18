-------------------------------------------------------------------------------
-- This file is auto-generated - do not edit by hand
--
--   Generator: scripts/gen_comm_lua.py
--   Source:    resources/positron-comms/ui-frontend-openrpc.json
-------------------------------------------------------------------------------

local util = require("jet.ark.comm.util")

local M = {}

---Document metadata
---@class jet.ark.comm.ui_frontend.text_document
---@field path string URI of the resource viewed in the editor
---@field eol string End of line sequence
---@field is_closed boolean Whether the document has been closed
---@field is_dirty boolean Whether the document has been modified
---@field is_untitled boolean Whether the document is untitled
---@field language_id string Language identifier
---@field line_count integer Number of lines in the document
---@field version integer Version number of the document

---A line and character position, such as the position of the cursor.
---@class jet.ark.comm.ui_frontend.position
---@field character integer The zero-based character value, as a Unicode code point offset.
---@field line integer The zero-based line value.

---Selection metadata
---@class jet.ark.comm.ui_frontend.selection
---@field active jet.ark.comm.ui_frontend.position Position of the cursor.
---@field start jet.ark.comm.ui_frontend.position Start position of the selection
---@field end jet.ark.comm.ui_frontend.position End position of the selection
---@field text string Text of the selection

---Selection range
---@class jet.ark.comm.ui_frontend.range
---@field start jet.ark.comm.ui_frontend.position Start position of the selection
---@field end jet.ark.comm.ui_frontend.position End position of the selection

---Source information for preview content
---@class jet.ark.comm.ui_frontend.preview_source
---@field type "runtime"|"terminal" The type of source that opened the preview
---@field id string The ID of the source (session_id or terminal process ID)

---@alias jet.ark.comm.ui_frontend.new_document.Reply any

---@alias jet.ark.comm.ui_frontend.show_question.Reply boolean

---@alias jet.ark.comm.ui_frontend.show_dialog.Reply any

---@alias jet.ark.comm.ui_frontend.show_prompt.Reply string

---@alias jet.ark.comm.ui_frontend.ask_for_password.Reply string

---@alias jet.ark.comm.ui_frontend.debug_sleep.Reply any

---@alias jet.ark.comm.ui_frontend.execute_command.Reply any

---@alias jet.ark.comm.ui_frontend.evaluate_when_clause.Reply boolean

---@alias jet.ark.comm.ui_frontend.execute_code.Reply any

---@alias jet.ark.comm.ui_frontend.workspace_folder.Reply string

---@alias jet.ark.comm.ui_frontend.modify_editor_selections.Reply any

---Editor metadata
---@class jet.ark.comm.ui_frontend.editor_context
---@field document jet.ark.comm.ui_frontend.text_document Document metadata
---@field contents string[] Document contents
---@field selection jet.ark.comm.ui_frontend.selection The primary selection, i.e. selections[0]
---@field selections jet.ark.comm.ui_frontend.selection[] The selections in this text editor.

---@alias jet.ark.comm.ui_frontend.last_active_editor_context.Reply jet.ark.comm.ui_frontend.editor_context

---@class jet.ark.comm.ui_frontend.busy.Params
---@field busy boolean Whether the backend is busy

---Change in backend's busy/idle status
---
---This represents the busy state of the underlying computation engine, not the busy state of the kernel. The kernel is busy when it is processing a request, but the runtime is busy only when a computation is running.
---@param kernel jet.Kernel
---@param params jet.ark.comm.ui_frontend.busy.Params
M.busy = function(kernel, params)
	return util.rpc_request(kernel, "positron.ui", "busy", params)
end

---Clear the console
---
---Use this to clear the console.
---@param kernel jet.Kernel
M.clear_console = function(kernel)
	return util.rpc_request(kernel, "positron.ui", "clear_console", nil)
end

---@class jet.ark.comm.ui_frontend.open_editor.Params
---@field file string The path of the file to open
---@field line integer The line number to jump to
---@field column integer The column number to jump to
---@field kind? "path"|"uri" How to interpret the 'file' argument: as a file path or as a URI. If omitted, defaults to 'path'.
---@field pinned? boolean Whether to open the editor pinned (non-preview mode). If omitted, defaults to true.

---Open an editor
---
---This event is used to open an editor with a given file and selection.
---@param kernel jet.Kernel
---@param params jet.ark.comm.ui_frontend.open_editor.Params
M.open_editor = function(kernel, params)
	return util.rpc_request(kernel, "positron.ui", "open_editor", params)
end

---@class jet.ark.comm.ui_frontend.new_document.Params
---@field contents string Document contents
---@field language_id string Language identifier

---Create a new document with text contents
---
---Use this to create a new document with the given language ID and text contents
---@param kernel jet.Kernel
---@param params jet.ark.comm.ui_frontend.new_document.Params
---@param callback? fun(res: jet.ark.comm.ui_frontend.new_document.Reply)
M.new_document = function(kernel, params, callback)
	return util.rpc_request(kernel, "positron.ui", "new_document", params, "NewDocumentReply", callback)
end

---@class jet.ark.comm.ui_frontend.show_message.Params
---@field message string The message to show to the user.

---Show a message
---
---Use this for messages that require immediate attention from the user
---@param kernel jet.Kernel
---@param params jet.ark.comm.ui_frontend.show_message.Params
M.show_message = function(kernel, params)
	return util.rpc_request(kernel, "positron.ui", "show_message", params)
end

---@class jet.ark.comm.ui_frontend.show_question.Params
---@field title string The title of the dialog
---@field message string The message to display in the dialog
---@field ok_button_title string The title of the OK button
---@field cancel_button_title string The title of the Cancel button

---Show a question
---
---Use this for a modal dialog that the user can accept or cancel
---@param kernel jet.Kernel
---@param params jet.ark.comm.ui_frontend.show_question.Params
---@param callback? fun(res: jet.ark.comm.ui_frontend.show_question.Reply)
M.show_question = function(kernel, params, callback)
	return util.rpc_request(kernel, "positron.ui", "show_question", params, "ShowQuestionReply", callback)
end

---@class jet.ark.comm.ui_frontend.show_dialog.Params
---@field title string The title of the dialog
---@field message string The message to display in the dialog

---Show a dialog
---
---Use this for a modal dialog that the user can only accept
---@param kernel jet.Kernel
---@param params jet.ark.comm.ui_frontend.show_dialog.Params
---@param callback? fun(res: jet.ark.comm.ui_frontend.show_dialog.Reply)
M.show_dialog = function(kernel, params, callback)
	return util.rpc_request(kernel, "positron.ui", "show_dialog", params, "ShowDialogReply", callback)
end

---@class jet.ark.comm.ui_frontend.show_prompt.Params
---@field title string The title of the prompt dialog, such as 'Enter Swallow Velocity'
---@field message string The message prompting the user for text, such as 'What is the airspeed velocity of an unladen swallow?'
---@field default string The default value with which to pre-populate the text input box, such as 'African or European?'
---@field timeout integer The number of seconds to wait for the user to reply before giving up.

---Show a prompt
---
---Use this for an input box where user can input any string
---@param kernel jet.Kernel
---@param params jet.ark.comm.ui_frontend.show_prompt.Params
---@param callback? fun(res: jet.ark.comm.ui_frontend.show_prompt.Reply)
M.show_prompt = function(kernel, params, callback)
	return util.rpc_request(kernel, "positron.ui", "show_prompt", params, "ShowPromptReply", callback)
end

---@class jet.ark.comm.ui_frontend.ask_for_password.Params
---@field prompt string The prompt, such as 'Please enter your password'

---Ask the user for a password
---
---Use this for an input box where the user can input a password
---@param kernel jet.Kernel
---@param params jet.ark.comm.ui_frontend.ask_for_password.Params
---@param callback? fun(res: jet.ark.comm.ui_frontend.ask_for_password.Reply)
M.ask_for_password = function(kernel, params, callback)
	return util.rpc_request(kernel, "positron.ui", "ask_for_password", params, "AskForPasswordReply", callback)
end

---@class jet.ark.comm.ui_frontend.prompt_state.Params
---@field input_prompt string Prompt for primary input.
---@field continuation_prompt string Prompt for incomplete input.

---New state of the primary and secondary prompts
---
---Languages like R allow users to change the way their prompts look. This event signals a change in the prompt configuration.
---@param kernel jet.Kernel
---@param params jet.ark.comm.ui_frontend.prompt_state.Params
M.prompt_state = function(kernel, params)
	return util.rpc_request(kernel, "positron.ui", "prompt_state", params)
end

---@class jet.ark.comm.ui_frontend.working_directory.Params
---@field directory string The new working directory

---Change the displayed working directory
---
---This event signals a change in the working direcotry of the interpreter
---@param kernel jet.Kernel
---@param params jet.ark.comm.ui_frontend.working_directory.Params
M.working_directory = function(kernel, params)
	return util.rpc_request(kernel, "positron.ui", "working_directory", params)
end

---@class jet.ark.comm.ui_frontend.debug_sleep.Params
---@field ms number Duration in milliseconds

---Sleep for n seconds
---
---Useful for testing in the backend a long running frontend method
---@param kernel jet.Kernel
---@param params jet.ark.comm.ui_frontend.debug_sleep.Params
---@param callback? fun(res: jet.ark.comm.ui_frontend.debug_sleep.Reply)
M.debug_sleep = function(kernel, params, callback)
	return util.rpc_request(kernel, "positron.ui", "debug_sleep", params, "DebugSleepReply", callback)
end

---@class jet.ark.comm.ui_frontend.execute_command.Params
---@field command string The command to execute

---Execute a Positron command
---
---Use this to execute a Positron command from the backend (like from a runtime), and wait for the command to finish
---@param kernel jet.Kernel
---@param params jet.ark.comm.ui_frontend.execute_command.Params
---@param callback? fun(res: jet.ark.comm.ui_frontend.execute_command.Reply)
M.execute_command = function(kernel, params, callback)
	return util.rpc_request(kernel, "positron.ui", "execute_command", params, "ExecuteCommandReply", callback)
end

---@class jet.ark.comm.ui_frontend.evaluate_when_clause.Params
---@field when_clause string The values for context keys, as a `when` clause

---Get a logical for a `when` clause (a set of context keys)
---
---Use this to evaluate a `when` clause of context keys in the frontend
---@param kernel jet.Kernel
---@param params jet.ark.comm.ui_frontend.evaluate_when_clause.Params
---@param callback? fun(res: jet.ark.comm.ui_frontend.evaluate_when_clause.Reply)
M.evaluate_when_clause = function(kernel, params, callback)
	return util.rpc_request(kernel, "positron.ui", "evaluate_when_clause", params, "EvaluateWhenClauseReply", callback)
end

---@class jet.ark.comm.ui_frontend.execute_code.Params
---@field language_id string The language ID of the code to execute
---@field code string The code to execute
---@field focus boolean Whether to focus the runtime's console
---@field allow_incomplete boolean Whether to bypass runtime code completeness checks

---Execute code in a Positron runtime
---
---Use this to execute code in a Positron runtime
---@param kernel jet.Kernel
---@param params jet.ark.comm.ui_frontend.execute_code.Params
---@param callback? fun(res: jet.ark.comm.ui_frontend.execute_code.Reply)
M.execute_code = function(kernel, params, callback)
	return util.rpc_request(kernel, "positron.ui", "execute_code", params, "ExecuteCodeReply", callback)
end

---@class jet.ark.comm.ui_frontend.open_workspace.Params
---@field path string The path for the workspace to be opened
---@field new_window boolean Should the workspace be opened in a new window?

---Open a workspace
---
---Use this to open a workspace in Positron
---@param kernel jet.Kernel
---@param params jet.ark.comm.ui_frontend.open_workspace.Params
M.open_workspace = function(kernel, params)
	return util.rpc_request(kernel, "positron.ui", "open_workspace", params)
end

---Path to the workspace folder
---
---Returns the path to the workspace folder, or first folder if there are multiple.
---@param kernel jet.Kernel
---@param callback? fun(res: jet.ark.comm.ui_frontend.workspace_folder.Reply)
M.workspace_folder = function(kernel, callback)
	return util.rpc_request(kernel, "positron.ui", "workspace_folder", nil, "WorkspaceFolderReply", callback)
end

---@class jet.ark.comm.ui_frontend.set_editor_selections.Params
---@field selections jet.ark.comm.ui_frontend.range[] The selections (really, ranges) to set in the document

---Set the selections in the editor
---
---Use this to set the selection ranges/cursor in the editor
---@param kernel jet.Kernel
---@param params jet.ark.comm.ui_frontend.set_editor_selections.Params
M.set_editor_selections = function(kernel, params)
	return util.rpc_request(kernel, "positron.ui", "set_editor_selections", params)
end

---@class jet.ark.comm.ui_frontend.modify_editor_selections.Params
---@field selections jet.ark.comm.ui_frontend.range[] The selections (really, ranges) to set in the document
---@field values string[] The text values to insert at the selections

---Modify selections in the editor with a text edit
---
---Use this to edit a set of selection ranges/cursor in the editor
---@param kernel jet.Kernel
---@param params jet.ark.comm.ui_frontend.modify_editor_selections.Params
---@param callback? fun(res: jet.ark.comm.ui_frontend.modify_editor_selections.Reply)
M.modify_editor_selections = function(kernel, params, callback)
	return util.rpc_request(kernel, "positron.ui", "modify_editor_selections", params, "ModifyEditorSelectionsReply", callback)
end

---Context metadata for the last editor
---
---Returns metadata such as file path for the last editor selected by the user. The result may be undefined if there are no active editors.
---@param kernel jet.Kernel
---@param callback? fun(res: jet.ark.comm.ui_frontend.last_active_editor_context.Reply)
M.last_active_editor_context = function(kernel, callback)
	return util.rpc_request(kernel, "positron.ui", "last_active_editor_context", nil, "LastActiveEditorContextReply", callback)
end

---@class jet.ark.comm.ui_frontend.show_url.Params
---@field url string The URL to display
---@field source? jet.ark.comm.ui_frontend.preview_source Optional source information for the URL

---Show a URL in Positron's Viewer pane
---
---Causes the URL to be displayed inside the Viewer pane, and makes the Viewer pane visible.
---@param kernel jet.Kernel
---@param params jet.ark.comm.ui_frontend.show_url.Params
M.show_url = function(kernel, params)
	return util.rpc_request(kernel, "positron.ui", "show_url", params)
end

---@class jet.ark.comm.ui_frontend.show_html_file.Params
---@field path string The fully qualified filesystem path to the HTML file to display
---@field title string A title to be displayed in the viewer. May be empty, and can be superseded by the title in the HTML file.
---@field destination "plot"|"viewer"|"editor" Where the file should be shown in Positron: as an interactive plot, in the viewer pane, or in a new editor tab.
---@field height integer The desired height of the HTML viewer, in pixels. The special value 0 indicates that no particular height is desired, and -1 indicates that the viewer should be as tall as possible.

---Show an HTML file in Positron
---
---Causes the HTML file to be shown in Positron.
---@param kernel jet.Kernel
---@param params jet.ark.comm.ui_frontend.show_html_file.Params
M.show_html_file = function(kernel, params)
	return util.rpc_request(kernel, "positron.ui", "show_html_file", params)
end

---@class jet.ark.comm.ui_frontend.open_with_system.Params
---@field path string The file path to open with the system default application

---Open a file or folder with the system default application
---@param kernel jet.Kernel
---@param params jet.ark.comm.ui_frontend.open_with_system.Params
M.open_with_system = function(kernel, params)
	return util.rpc_request(kernel, "positron.ui", "open_with_system", params)
end

---Webview preloads should be flushed
---
---This event is used to signal that the stored messages the front-end replays when constructing multi-output plots should be reset. This happens for things like a holoviews extension being changed.
---@param kernel jet.Kernel
M.clear_webview_preloads = function(kernel)
	return util.rpc_request(kernel, "positron.ui", "clear_webview_preloads", nil)
end

return M
