function icon=getmatlabicons
iconlist={};
%filetype;
thisdir = fileparts(mfilename('fullpath'));
iconsdir = fullfile(fileparts(fileparts(thisdir)),'includes','icons');
iconlist{1} = ['folder=' fullfile(iconsdir, 'foldericon.gif')];
iconlist{end+1}=['file.page=' fullfile(iconsdir, 'pageicon.gif')];
iconlist{end+1}=['file.pdf=' fullfile(matlabroot, 'toolbox/matlab/icons/pdf.gif')];
iconlist{end+1}=['file.text=' fullfile(iconsdir, 'notesicon.gif')];
iconlist{end+1}=['file.mat=' fullfile(iconsdir, 'Results_16.png')];
iconlist{end+1}=['file.fig=' fullfile(iconsdir, 'filetype_m.gif')];
iconlist{end+1}=['file.m=' fullfile(matlabroot, 'help/matlab/filetype_m_function.png')];
iconlist{end+1}=['file.foldermat=' fullfile(iconsdir, 'matrixicon_folder.gif')];
iconlist{end+1}=['file.new=' fullfile(matlabroot, 'toolbox/matlab/icons/file_new.png')];

%variables
iconlist{end+1}=['vars.struct=' fullfile(iconsdir, 'variable_struct.png')];
iconlist{end+1}=['vars.num=' fullfile(iconsdir, 'SimulinkNumericType.png')];
iconlist{end+1}=['vars.cell=' fullfile(iconsdir, 'variable_cell.png')];

%Status
iconlist{end+1}=['status.warning=' fullfile(matlabroot, 'toolbox/matlab/icons/warning.gif')];
iconlist{end+1}=['status.check=' fullfile(matlabroot, 'toolbox/images/icons/CreateMask_24px.png')];
iconlist{end+1}=['status.matsaved=' fullfile(iconsdir, 'Analyze2_24.png')];
iconlist{end+1}=['status.error=' fullfile(iconsdir, 'error.png')];
iconlist{end+1}=['status.info=' fullfile(iconsdir, 'viewer_icon.gif')];
iconlist{end+1}=['status.fileloaded=' fullfile(iconsdir, 'Load_24.png')];
iconlist{end+1}=['status.saved=' fullfile(iconsdir, 'file_save.png')];
iconlist{end+1}=['status.stop=' fullfile(iconsdir, 'Stop_16.png')];
iconlist{end+1}=['status.working=' fullfile(iconsdir, 'working.png')];

%Actions
iconlist{end+1}=['action.play=' fullfile(iconsdir, 'greenarrowicon.gif')];
iconlist{end+1}=['action.save=' fullfile(iconsdir, 'file_save.png')];
iconlist{end+1}=['action.print=' fullfile(iconsdir, 'file_print.png')];
iconlist{end+1}=['action.open=' fullfile(iconsdir, 'file_open.png')];
iconlist{end+1}=['action.import=' fullfile(iconsdir, 'ImportXML_16.png')];
iconlist{end+1}=['action.export=' fullfile(iconsdir, 'export.png')];
iconlist{end+1}=['action.updir=' fullfile(iconsdir,'upfolder.gif')];
iconlist{end+1}=['action.finddir=' fullfile(matlabroot, 'help/matlab/matlab_prog/find_files_ts_16.png')];
iconlist{end+1}=['action.filter=' fullfile(matlabroot, 'toolbox/stm/stm/views/ResultsPane/images/Filter_16.png')];
iconlist{end+1}=['action.email=' fullfile(matlabroot, 'help/includes/product/images/global/icon_email.gif')];
iconlist{end+1}=['action.newfolder=' fullfile(matlabroot,'toolbox/simulink/simulink/modeladvisor/resources/folder_new.png')];
iconlist{end+1}=['action.delete=' fullfile(matlabroot,'toolbox/simulink/simulink/modeladvisor/resources/delete.png')];
iconlist{end+1}=['action.copy=' fullfile(matlabroot,'toolbox/simulink/simulink/modeladvisor/resources/copy.png')];
iconlist{end+1}=['action.refresh=' fullfile(iconsdir,'refresh.png')];
iconlist{end+1}=['action.view=' fullfile(iconsdir,'view.png')];
iconlist{end+1}=['action.update=' fullfile(matlabroot,'toolbox\shared\dastudio\resources\glue\Toolbars\16px\UpdateDiagram_16.png')];
iconlist{end+1}=['action.scan=' fullfile(iconsdir, 'serialRead32.png')];
iconlist{end+1}=['action.zero=' fullfile(iconsdir, 'zero.jpg')];
iconlist{end+1}=['action.openfolder=' fullfile(iconsdir, 'file_open.jpg')];
iconlist{end+1}=['action.assign=' fullfile(iconsdir, 'assign.png')];
% EEG related
iconlist{end+1}=['eeg.selectcomp=' fullfile(iconsdir, 'selectcomp.jpg')];
iconlist{end+1}=['eeg.dipplot=' fullfile(iconsdir, 'dipplot.jpg')];
iconlist{end+1}=['brainvision=' fullfile(iconsdir,'brainvision.png')];
iconlist{end+1}=['brainsignal=' fullfile(iconsdir,'signal.png')];
iconlist{end+1}=['brain=' fullfile(iconsdir,'brainicon.png')];
%Web
iconlist{end+1}=['web=' fullfile(matlabroot,'toolbox/matlab/icons/webicon.gif')];
%Other
iconlist{end+1}=['bulb=' fullfile(matlabroot,'toolbox/matlab/icons/greenarrowicon.gif')];
iconlist{end+1}=['matlab=' fullfile(matlabroot,'toolbox/matlab/icons/matlabicon.gif')];
iconlist{end+1}=['figure=' fullfile(matlabroot,'toolbox/shared/dastudio/resources/image.png')];
iconlist{end+1}=['function=' fullfile(matlabroot,'help/matlab/matlab_prog/help_fx.png')];
iconlist{end+1}=['link=' fullfile(matlabroot,'help/simulink/ug/library_link_enabled.png')];
iconlist{end+1}=['walk=' fullfile(iconsdir,'walking-16.png')];
iconlist{end+1}=['leftfoot=' fullfile(iconsdir,'leftfoot16.jpg')];
iconlist{end+1}=['rightfoot=' fullfile(iconsdir,'rightfoot16.jpg')];
iconlist{end+1}=['uh=' fullfile(iconsdir,'uhlogo12.png')];
iconlist{end+1}=['uh300=' fullfile(iconsdir,'uhlogo300.png')];
iconlist{end+1}=['uh100=' fullfile(iconsdir,'uhlogo100.png')];
iconlist{end+1}=['uh50=' fullfile(iconsdir,'uhlogo50.png')];
iconlist{end+1}=['logo=' fullfile(iconsdir,'brainactivity.gif')];
iconlist{end+1}=['user=' fullfile(iconsdir,'user.png')];
iconlist{end+1}=['checkeduser=' fullfile(iconsdir,'checkeduser.png')];
iconlist{end+1}=['yes=' fullfile(iconsdir,'yes.png')];
iconlist{end+1}=['no=' fullfile(iconsdir,'no.png')];
iconlist{end+1}=['color.pink=' fullfile(iconsdir,'pink.png')];
iconlist{end+1}=['color.blue=' fullfile(iconsdir,'blue.png')];
iconlist{end+1}=['color.black=' fullfile(iconsdir,'fontColorBlack.png')];
iconlist{end+1}=['color.white=' fullfile(iconsdir,'fontColorWhite.png')];
iconlist{end+1}=['pcguy=' fullfile(iconsdir,'pcguy.png')];
iconlist{end+1}=['therapist=' fullfile(iconsdir,'therapist.png')];
iconlist{end+1}=['calendar=' fullfile(iconsdir,'calendar.gif')];
iconlist{end+1}=['arrowleft=' fullfile(matlabroot,'toolbox/shared/controllib/general/resources/Arrow_Forward_16.png')];
iconlist{end+1}=['arrowright=' fullfile(matlabroot,'toolbox/shared/controllib/general/resources/Arrow_Back_16.png')];
iconlist{end+1}=['arrowup=' fullfile(matlabroot,'help/matlab/env_csh/arrow_move_up.png')];
iconlist{end+1}=['arrowdown=' fullfile(matlabroot,'help/matlab/env_csh/arrow_move_down.png')];
iconlist{end+1}=['arrowupdown=' fullfile(iconsdir,'arrow-double-up-down-32.png')];
iconlist{end+1}=['serial=' fullfile(iconsdir, 'serialport.png')];
iconlist{end+1}=['freq=' fullfile(iconsdir, 'freq32.png')];
iconlist{end+1}=['sine=' fullfile(iconsdir, 'sine.png')];
iconlist{end+1}=['datalog=' fullfile(iconsdir, 'DataLog.png')];

for i=1:length(iconlist)
    thisicon=iconlist{i};
%     thisicon=thisicon(find(~isspace(thisicon)));
    iconname=thisicon(1:strfind(thisicon,'=')-1);
    iconpath=thisicon(strfind(thisicon,'=')+1:end);
    if strcmpi(iconpath(1),'.')
        iconfullpath = fullfile(cd,iconpath(3:end));
    elseif strcmpi(iconpath(2),':')
        iconfullpath = iconpath;
    else
        iconfullpath = fullfile(matlabroot,iconpath);
    end
    iconfullpath=strrep(iconfullpath,'\','/');
    cmdstr=sprintf('icon.%s = ''%s'';',iconname,iconfullpath);
    eval(cmdstr);
end
