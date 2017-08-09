I18n.translations || (I18n.translations = {});
I18n.translations["en-CA"] = I18n.extend((I18n.translations["en-CA"] || {}), {"js":{"ajax":{"hide":"Hide","loading":"Loading ..."},"button_add_watcher":"Add watcher","button_back_to_list_view":"Back to list view","button_cancel":"Cancel","button_check_all":"Check all","button_close":"Close","button_close_details":"Close details view","button_configure-form":"Configure form","button_confirm":"Confirm","button_continue":"Continue","button_copy":"Copy","button_custom-fields":"Custom fields","button_delete":"Delete","button_delete_watcher":"Delete watcher","button_details_view":"Details view","button_duplicate":"Duplicate","button_edit":"Edit","button_export-atom":"Download Atom","button_export-pdf":"Download PDF","button_filter":"Filter","button_list_view":"List view","button_log_time":"Log time","button_more":"More","button_move":"Move","button_open_details":"Open details view","button_open_fullscreen":"Open fullscreen view","button_quote":"Quote","button_save":"Save","button_settings":"Settings","button_show_view":"Fullscreen view","button_uncheck_all":"Uncheck all","button_update":"Update","clipboard":{"browser_error":"Your browser doesn't support copying to clipboard. Please copy the selected text manually.","copied_successful":"Sucessfully copied to clipboard!"},"close_filter_title":"Close filter","close_form_title":"Close form","close_popup_title":"Close popup","description_available_columns":"Available Columns","description_current_position":"You are here:","description_select_work_package":"Select work package #%{id}","description_selected_columns":"Selected Columns","description_subwork_package":"Child of work package #%{id}","error":{"internal":"An internal error has occurred."},"error_could_not_resolve_user_name":"Couldn't resolve user name","error_could_not_resolve_version_name":"Couldn't resolve version name","field_value_enter_prompt":"Enter a value for '%{field}'","filter":{"description":{"text_close_filter":"To select an entry leave the focus for example by pressing enter. To leave without filter select the first (empty) entry.","text_open_filter":"Open this filter with 'ALT' and arrow keys."},"noneElement":"(none)","sorting":{"criteria":{"one":"First sorting criteria","three":"Third sorting criteria","two":"Second sorting criteria"}},"time_zone_converted":{"only_end":"Till %{to} in your local time.","only_start":"From %{from} in your local time.","two_values":"%{from} - %{to} in your local time."},"value_spacer":"-"},"general_text_No":"No","general_text_Yes":"Yes","general_text_no":"no","general_text_yes":"yes","help_texts":{"show_modal":"Show attribute help text entry"},"inplace":{"btn_preview_disable":"Disable preview","btn_preview_enable":"Preview","button_cancel":"%{attribute}: Cancel","button_cancel_all":"Cancel","button_edit":"%{attribute}: Edit","button_save":"%{attribute}: Save","button_save_all":"Save","clear_value_label":"-","errors":{"maxlength":"%{field} cannot contain more than %{maxLength} digit(s)","messages_on_field":"This field is invalid: %{messages}","minlength":"%{field} cannot contain less than %{minLength} digit(s)","number":"%{field} is not a valid number","required":"%{field} cannot be empty"},"link_formatting_help":"Text formatting help","null_value_label":"No value"},"label_activate":"Activate","label_activity_no":"Activity entry number %{activityNo}","label_activity_show_all":"Show all activities","label_activity_show_only_comments":"Show activities with comments only","label_activity_with_comment_no":"Activity entry number %{activityNo}. Has a user comment.","label_add_attachments":"Add attachments","label_add_columns":"Add columns","label_add_comment":"Add comment","label_add_comment_title":"Click to add a comment","label_add_description":"Add a description for %{file}","label_add_selected_columns":"Add selected columns","label_added_by":"added by","label_added_time_by":"Added by %{author} %{age}","label_ago":"days ago","label_all":"all","label_all_work_packages":"all work packages","label_and":"and","label_ascending":"Ascending","label_attachments":"Files","label_author":"Author: %{user}","label_between":"between","label_board_locked":"Locked","label_board_sticky":"Sticky","label_cancel_comment":"Cancel comment","label_closed_work_packages":"closed","label_collapse":"Collapse","label_collapse_all":"Collapse all","label_collapsed":"collapsed","label_columns":"Columns","label_comment":"Comment","label_committed_at":"%{committed_revision_link} at %{date}","label_committed_link":"committed revision %{revision_identifier}","label_contains":"contains","label_create_work_package":"Create new work package","label_created_by":"Created by","label_created_on":"created on","label_custom_queries":"Private queries","label_date":"Date","label_date_with_format":"Enter the %{date_attribute} using the following format: %{format}","label_deactivate":"Deactivate","label_descending":"Descending","label_description":"Description","label_drop_files":"Drop files here","label_drop_files_hint":"or click to add files","label_edit_comment":"Edit this comment","label_equals":"is","label_expand":"Expand","label_expand_all":"Expand all","label_expanded":"expanded","label_export":"Export","label_filename":"File","label_files_to_upload":"These files will be uploaded:","label_filesize":"Size","label_formattable_attachment_hint":"Attach and link files by dropping on this field, or pasting from the clipboard.","label_global_queries":"Shared queries","label_greater_or_equal":"\u003e=","label_group_by":"Group by","label_hide_attributes":"Show less","label_hide_column":"Hide column","label_in":"in","label_in_less_than":"in less than","label_in_more_than":"in more than","label_last_updated_on":"Last updated on","label_latest_activity":"Latest Activity","label_less_or_equal":"\u003c=","label_less_than_ago":"less than days ago","label_loading":"Loading...","label_me":"me","label_menu_collapse":"collapse","label_menu_expand":"expand","label_more_than_ago":"more than days ago","label_next":"Next","label_no_data":"No data to display","label_no_due_date":"no end date","label_no_start_date":"no start date","label_none":"none","label_not_contains":"doesn't contain","label_not_equals":"is not","label_on":"on","label_open_menu":"Open menu","label_open_work_packages":"open","label_password":"Password","label_per_page":"Per page:","label_please_wait":"Please wait","label_previous":"Previous","label_quote_comment":"Quote this comment","label_rejected_files":"These files cannot be uploaded:","label_rejected_files_reason":"These files cannot be uploaded as their size is greater than %{maximumFilesize}","label_remove_all_files":"Delete all files","label_remove_columns":"Remove selected columns","label_remove_file":"Delete %{fileName}","label_remove_watcher":"Remove watcher %{name}","label_reset":"Reset","label_save_as":"Save as","label_select_watcher":"Select a watcher...","label_selected_filter_list":"Selected filters","label_show_attributes":"Show all attributes","label_show_in_menu":"Show page in menu","label_sort_by":"Sort by","label_sort_higher":"Move up","label_sort_lower":"Move down","label_sorted_by":"sorted by","label_sorting":"Sorting","label_subject":"Subject","label_sum_for":"Sum for","label_this_week":"this week","label_today":"today","label_total_progress":"%{percent}% Total progress","label_unwatch":"Unwatch","label_unwatch_work_package":"Unwatch work package","label_updated_on":"updated on","label_upload_counter":"%{done} of %{count} files finished","label_upload_notification":"Uploading files for Work package #%{id}: %{subject}","label_uploaded_by":"Uploaded by","label_validation_error":"The work package could not be saved due to the following errors:","label_visibility_settings":"Visibility settings","label_visible_for_others":"Page visible for others","label_wait":"Please wait for configuration...","label_watch":"Watch","label_watch_work_package":"Watch work package","label_watcher_added_successfully":"Watcher successfully added!","label_watcher_deleted_successfully":"Watcher successfully deleted!","label_work_package":"Work package","label_work_package_details_you_are_here":"You're on the %{tab} tab for %{type} %{subject}.","label_work_package_plural":"Work packages","modals":{"button_apply":"Apply","button_cancel":"Cancel","button_save":"Save","button_submit":"Submit","form_submit":{"text":"Are you sure you want to perform this action?","title":"Confirm to continue"},"label_delete_page":"Delete current page","label_name":"Name","label_settings":"Rename query"},"notice_bad_request":"Bad Request.","notice_successful_create":"Successful creation.","notice_successful_delete":"Successful deletion.","notice_successful_update":"Successful update.","pagination":{"no_other_page":"You are on the only page.","pages":{"next":"Forward to the next page","previous":"Back to the previous page"}},"password_confirmation":{"field_description":"You need to enter your account password to confirm this change.","title":"Confirm your password to continue"},"placeholders":{"default":"-","relation_description":"Click to add description for this relation","selection":"Please select"},"relation_buttons":{"abort":"Abort","add_existing_child":"Add existing child","add_follower":"Add follower","add_new_child":"Create new child","add_new_relation":"Create new relation","add_parent":"Add existing parent","add_predecessor":"Add predecessor","change_parent":"Change parent","group_by_relation_type":"Group by relation type","group_by_wp_type":"Group by work package type","remove":"Remove relation","remove_child":"Remove child","remove_parent":"Remove parent","save":"Save relation","toggle_description":"Toggle relation description","update_description":"Set or update description of this relation","update_relation":"Click to change the relation type"},"relation_labels":{"blocked":"Blocked by","blocks":"Blocks","children":"Children","duplicated":"Duplicated by","duplicates":"Duplicates","follows":"Follows","includes":"Includes","parent":"Parent","partof":"Part of","precedes":"Precedes","relates":"Related To","relation_type":"relation type","required":"Required by","requires":"Requires"},"relations":{"empty":"No relation exists","remove":"Remove relation"},"relations_autocomplete":{"placeholder":"Enter the related work package id"},"relations_hierarchy":{"hierarchy_headline":"hierarchy"},"repositories":{"select_branch":"Select branch","select_tag":"Select tag"},"select2":{"input_too_short":{"one":"Please enter one more character","other":"Please enter {{count}} more characters","zero":"Please enter more characters"},"load_more":"Loading more results ...","no_matches":"No matches found","searching":"Searching ...","selection_too_big":{"one":"You can only select one item","other":"You can only select {{limit}} items","zero":"You cannot select any items"}},"sort":{"activate_asc":"activate to apply an ascending sort","activate_dsc":"activate to apply a descending sort","activate_no":"activate to remove the sort","sorted_asc":"Ascending sort applied, ","sorted_dsc":"Descending sort applied, ","sorted_no":"No sort applied, ","sorting_disabled":"sorting is disabled"},"text_are_you_sure":"Are you sure?","text_attachment_destroy_confirmation":"Are you sure you want to delete the attachment?","text_query_destroy_confirmation":"Are you sure you want to delete the selected query?","text_work_packages_destroy_confirmation":"Are you sure you want to delete the selected work package(s)?","timelines":{"button_activate":"Activate timeline mode","button_deactivate":"Deactivate timeline mode","cancel":"Cancel","change":"Change in planning","due_date":"Due date","empty":"(empty)","error":"An error has occurred.","errors":{"not_implemented":"The timeline could not be rendered because it uses a feature that is not yet implemented.","report_comparison":"The timeline could not render the configured comparisons. Please check the appropriate section in the configuration, resetting it can help solve this problem.","report_epicfail":"The timeline could not be loaded due to an unexpected error.","report_timeout":"The timeline could not be loaded in a reasonable amount of time."},"filter":{"column":{"assigned_to":"Assignee","due_date":"End date","name":"Name","responsible":"Responsible","start_date":"Start date","status":"Status","type":"Type"},"grouping_other":"Other","noneSelection":"(none)"},"name":"Name","new_work_package":"New work package","outline":"Reset Outline","outlines":{"aggregation":"Show aggregations only","all":"Show all","level1":"Expand level 1","level2":"Expand level 2","level3":"Expand level 3","level4":"Expand level 4","level5":"Expand level 5"},"project_status":"Project status","project_type":"Project type","really_close_dialog":"Do you really want to close the dialog and lose the entered data?","responsible":"Responsible","save":"Save","selection_mode":{"notification":"Click on any highlighted work package to create the relation. Press escape to cancel."},"start_date":"Start date","tooManyProjects":"More than %{count} Projects. Please use a better filter!","zoom":{"days":"Days","in":"Zoom in","months":"Months","out":"Zoom out","quarters":"Quarters","slider":"Zoom slider","weeks":"Weeks","years":"Years"}},"tl_toolbar":{"outlines":"Hierarchy level","zooms":"Zoom level"},"toolbar":{"filter":"Filter","search_query_label":"Search saved filter queries","search_query_title":"Click to search saved filter queries","settings":{"columns":"Columns ...","delete":"Delete","display_hierarchy":"Display hierarchy","display_sums":"Display sums","export":"Export ...","group_by":"Group by ...","hide_hierarchy":"Hide hierarchy","hide_sums":"Hide sums","page_settings":"Rename query ...","publish":"Publish ...","save":"Save","save_as":"Save as ...","sort_by":"Sort by ..."},"unselected_title":"Work package"},"types":{"attribute_groups":{"confirm_reset":"Warning: Are you sure you want to reset the form configuration? This will reset the attributes to their default group, unset the visibility checkboxes, and disable ALL custom fields.\n","error_duplicate_group_name":"The name %{group} is used more than once. Group names must be unique.","more_information":"More information","nevermind":"Nevermind","reset_title":"Reset form configuration","upgrade_to_ee":"Upgrade to Enterprise Edition","upgrade_to_ee_text":"Wow! If you need this feature you are a super pro! Would you mind supporting us OpenSource developers by becoming an Enterprise Edition client?"}},"units":{"hour":{"one":"1 hour","other":"%{count} hours","zero":"0 hours"}},"unsupported_browser":{"close_warning":"Ignore this warning.","learn_more":"Learn more","message":"The browser version you are using is no longer supported by OpenProject.","title":"Your browser version is not supported","update_ie_user":"Please switch to Mozilla Firefox or Google Chrome, or upgrade to Microsoft Edge.","update_message":"Please update your browser."},"watchers":{"label_add":"Add watchers","label_discard":"Discard selection","label_error_loading":"An error occurred while loading the watchers","label_loading":"loading watchers...","label_search_watchers":"Search watchers","typeahead_placeholder":"Search for possible watchers"},"wiki_formatting":{"code":"Inline Code","deleted":"Deleted","heading1":"Heading 1","heading2":"Heading 2","heading3":"Heading 3","image":"Image","italic":"Italic","ordered_list":"Ordered List","preformatted_text":"Preformatted Text","quote":"Quote","strong":"Strong","underline":"Underline","unordered_list":"Unordered List","unquote":"Unquote","wiki_link":"Link to a Wiki page"},"work_packages":{"bulk_actions":{"copy":"Bulk copy","delete":"Bulk delete","edit":"Bulk edit","move":"Bulk move"},"button_clear":"Clear","comment_added":"The comment was successfully added.","comment_send_failed":"An error has occurred. Could not submit the comment.","comment_updated":"The comment was successfully updated.","confirm_edit_cancel":"Are you sure you want to cancel editing the work package?","create":{"button":"Create","header":"New %{type}","header_no_type":"New work package (Type not yet set)","header_with_parent":"New %{type} (Child of %{parent_type} #%{id})"},"description_enter_text":"Enter text","description_filter":"Filter","description_options_hide":"Hide options","description_options_show":"Show options","edit_attribute":"%{attribute} - Edit","error":{"edit_prohibited":"Editing %{attribute} is blocked for this work package. Either this attribute is derived from relations (e.g, children) or otherwise not configurable.","format":{"date":"%{attribute} is no valid date - YYYY-MM-DD expected."},"general":"An error has occurred."},"faulty_query":{"description":"Your query is erroneous and could not be processed.","title":"Work packages could not be loaded."},"hierarchy":{"children_collapsed":"Hierarchy level %{level}, collapsed. Click to show the filtered children","children_expanded":"Hierarchy level %{level}, expanded. Click to collapse the filtered children","hide":"Hide hierarchy mode","leaf":"Work package leaf at level %{level}.","show":"Show hierarchy mode","toggle_button":"Click to toggle hierarchy mode."},"inline_create":{"title":"Click here to add a new work package to this list"},"jump_marks":{"content":"Jump to content","label_content":"Click here to skip over the menu and go to the content","label_pagination":"Click here to skip over the work packages table and go to pagination","pagination":"Jump to table pagination"},"key_value":"%{key}: %{value}","label_column_multiselect":"Combined dropdown field: Select with arrow keys, confirm selection with enter, delete with backspace","label_disable_multi_select":"Disable multiselect","label_enable_multi_select":"Enable multiselect","label_filter_add":"Add filter","label_options":"Options","label_switch_to_multi_select":"Switch to multi select","label_switch_to_single_select":"Switch to single select","message_error_during_bulk_delete":"An error occurred while trying to delete work packages.","message_successful_bulk_delete":"Successfully deleted work packages.","message_successful_show_in_fullscreen":"Click here to open this work package in fullscreen view.","message_view_spent_time":"Show spent time for this work package","no_results":{"description":"Either none have been created or all work packages are filtered out.","title":"No work packages to display."},"no_value":"No value","placeholders":{"default":"-","description":"Click to enter description..."},"properties":{"assignee":"Assignee","author":"Author","category":"Category","createdAt":"Created on","date":"Date","description":"Description","dueDate":"Due date","estimatedTime":"Estimated time","percentageDone":"Percentage done","priority":"Priority","projectName":"Project","responsible":"Responsible","spentTime":"Spent time","startDate":"Start date","status":"Status","subject":"Subject","title":"Title","type":"Type","updatedAt":"Updated on","version":"Version","versionName":"Version"},"property_groups":{"details":"Details","estimatesAndTime":"Estimates \u0026 Time","other":"Other","people":"People"},"query":{"column_names":"Columns","display_sums":"Display Sums","errors":{"not_found":"There is no such query","unretrievable_query":"Unable to retrieve query from URL"},"filters":"Filters","group":"Group by","group_by":"Group results by","group_by_disabled_by_hierarchy":"Group by is disabled due to the hierarchy mode being active.","hide_column":"Hide column","hierarchy_disabled_by_group_by":"Hierarchy mode is disabled due to results being grouped by %{column}.","hierarchy_mode":"Hierarchy mode","insert_columns":"Insert columns ...","move_column_left":"Move column left","move_column_right":"Move column right","sort_ascending":"Sort ascending","sort_descending":"Sort descending","text_no_results":"No matching queries were found."},"table":{"summary":"Table with rows of work package and columns of work package attributes.","text_inline_edit":"Most cells of this table are buttons that activate inline-editing functionality of that attribute.","text_select_hint":"Select boxes should be opened with 'ALT' and arrow keys.","text_sort_hint":"With the links in the table headers you can sort, group, reorder, remove and add table columns."},"tabs":{"activity":"Activity","attachments":"Attachments","overview":"Overview","relations":"Relations","watchers":"Watchers"},"time_relative":{"days":"days","months":"months","weeks":"weeks"}},"zen_mode":{"button_activate":"Activate zen mode","button_deactivate":"Deactivate zen mode"}}});
