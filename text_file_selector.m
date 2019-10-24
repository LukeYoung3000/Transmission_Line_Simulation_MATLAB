function [list,selection] = text_file_selector()

list = dir('*.txt');
list = {list.name};

selection = listdlg('liststring',list);

disp(['-------------' list{selection} '---------------']);

end

