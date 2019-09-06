unit UBSExplorer.Main;

interface

uses
  System.Actions,
  System.Classes,
  System.ImageList,
  System.SysUtils,
  System.IOUtils,
  System.UITypes,

  Winapi.ShellAPI,
  Winapi.Messages,

  Vcl.ImgList,
  Vcl.Forms,
  Vcl.ActnList,
  Vcl.Menus,
  Vcl.Controls,
  Vcl.ComCtrls,
  Vcl.ToolWin,
  Vcl.Dialogs,
  Vcl.AppEvnts,

  Pengine.WinUtility,
  Pengine.ICollections,

  Unbound.Game.Serialization,

  UBSExplorer.Tab,
  UBSExplorer.DataModule,
  UBSExplorer.RegistrySettings;

type

  TfrmMain = class(TForm)
    mmMain: TMainMenu;
    sbMain: TStatusBar;
    File1: TMenuItem;
    miExit: TMenuItem;
    alMain: TActionList;
    miNew: TMenuItem;
    miOpen: TMenuItem;
    miSaveAs: TMenuItem;
    N2: TMenuItem;
    N1: TMenuItem;
    actOpen: TAction;
    actSave: TAction;
    actSaveAs: TAction;
    actExit: TAction;
    miSave: TMenuItem;
    actNewMap: TAction;
    actNewList: TAction;
    miNewMap: TMenuItem;
    miNewList: TMenuItem;
    miRegsiterExtension: TMenuItem;
    actRegisterExtension: TAction;
    pcTabs: TPageControl;
    aeEvents: TApplicationEvents;
    actClose: TAction;
    miClose: TMenuItem;
    miEdit: TMenuItem;
    miModifyValue: TMenuItem;
    miAddValue: TMenuItem;
    miDelete: TMenuItem;
    N4: TMenuItem;
    miAddMap: TMenuItem;
    miAddList: TMenuItem;
    N5: TMenuItem;
    miFind: TMenuItem;
    miHelp: TMenuItem;
    miAbout: TMenuItem;
    tbMain: TToolBar;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton1: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    actAddMap: TAction;
    actAbout: TAction;
    actAddList: TAction;
    actAddValue: TAction;
    actEditValue: TAction;
    actDeleteValue: TAction;
    actFind: TAction;
    actFindNext: TAction;
    miFindNext: TMenuItem;
    actMoveUp: TAction;
    actMoveDown: TAction;
    N6: TMenuItem;
    miMoveUp: TMenuItem;
    miMoveDown: TMenuItem;
    actSettings: TAction;
    miSettings: TMenuItem;
    miTools: TMenuItem;
    N7: TMenuItem;
    actDarkTheme: TAction;
    miDarkTheme: TMenuItem;
    actSaveAll: TAction;
    miSaveAll: TMenuItem;
    actRenameValue: TAction;
    actRenameValue1: TMenuItem;
    procedure actAddListExecute(Sender: TObject);
    procedure actAddListUpdate(Sender: TObject);
    procedure actAddMapExecute(Sender: TObject);
    procedure actAddMapUpdate(Sender: TObject);
    procedure actAddValueExecute(Sender: TObject);
    procedure actAddValueUpdate(Sender: TObject);
    procedure actCloseExecute(Sender: TObject);
    procedure actCloseUpdate(Sender: TObject);
    procedure actDarkThemeExecute(Sender: TObject);
    procedure actDarkThemeUpdate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure actExitExecute(Sender: TObject);
    procedure actNewListExecute(Sender: TObject);
    procedure actNewMapExecute(Sender: TObject);
    procedure actOpenExecute(Sender: TObject);
    procedure actRegisterExtensionExecute(Sender: TObject);
    procedure actRegisterExtensionUpdate(Sender: TObject);
    procedure actSaveAllExecute(Sender: TObject);
    procedure actSaveAllUpdate(Sender: TObject);
    procedure actSaveAsExecute(Sender: TObject);
    procedure actSaveAsUpdate(Sender: TObject);
    procedure actSaveExecute(Sender: TObject);
    procedure actSaveUpdate(Sender: TObject);
    procedure aeEventsActivate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure pcTabsChange(Sender: TObject);
    procedure pcTabsMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ToolButton1Click(Sender: TObject);
  private
    procedure WMDropFiles(var Msg: TWMDropFiles); message WM_DROPFILES;

    procedure OpenTab(AFilename: string);
    procedure OpenNew(AUBSTag: TUBSTag);

    function GetActiveTab: TfrmTab;

    procedure UpdateCaption(const ATab: TfrmTab);

    procedure FilenameChange(const ATab: TfrmTab);
    procedure ModifiedChange(const ATab: TfrmTab);

  public
    function HasTab: Boolean;
    property ActiveTab: TfrmTab read GetActiveTab;

  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

uses
  UBSExplorer.EditValueDialog;

procedure TfrmMain.actAddListExecute(Sender: TObject);
begin
  ActiveTab.AddValue(utList);
end;

procedure TfrmMain.actAddListUpdate(Sender: TObject);
begin
  actAddList.Enabled := HasTab and ActiveTab.CanAddValue;
end;

procedure TfrmMain.actAddMapExecute(Sender: TObject);
begin
  ActiveTab.AddValue(utMap);
end;

procedure TfrmMain.actAddMapUpdate(Sender: TObject);
begin
  actAddMap.Enabled := HasTab and ActiveTab.CanAddValue;
end;

procedure TfrmMain.actAddValueExecute(Sender: TObject);
begin
  ActiveTab.AddValue;
end;

procedure TfrmMain.actAddValueUpdate(Sender: TObject);
begin
  actAddValue.Enabled := HasTab and ActiveTab.CanAddValue;
end;

procedure TfrmMain.actCloseExecute(Sender: TObject);
begin
  ActiveTab.TryClose;
end;

procedure TfrmMain.actCloseUpdate(Sender: TObject);
begin
  actClose.Enabled := HasTab;
end;

procedure TfrmMain.actDarkThemeExecute(Sender: TObject);
begin
  if Settings.Theme = 'Windows' then
    Settings.Theme := 'Carbon'
  else
    Settings.Theme := 'Windows';
end;

procedure TfrmMain.actDarkThemeUpdate(Sender: TObject);
begin
  actDarkTheme.Checked := Settings.Theme = 'Carbon';
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  case ParamCount of
    1:
      OpenTab(ParamStr(1));
  end;
  DragAcceptFiles(Handle, True);
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  DragAcceptFiles(Handle, False);
end;

procedure TfrmMain.actExitExecute(Sender: TObject);
begin
  Close;
end;

procedure TfrmMain.actNewListExecute(Sender: TObject);
begin
  OpenNew(utList);
end;

procedure TfrmMain.actNewMapExecute(Sender: TObject);
begin
  OpenNew(utMap);
end;

procedure TfrmMain.actOpenExecute(Sender: TObject);
var
  Path: string;
begin
  if dmData.dlgOpen.Execute then
    for Path in dmData.dlgOpen.Files do
      OpenTab(Path);
end;

procedure TfrmMain.actRegisterExtensionExecute(Sender: TObject);
begin
  case ExtensionRegistered('.ubs') of
    epMissing:
      if RegisterExtension('.ubs', 'UBS-Explorer', 'Unbound-Storage') then
        MessageDlg('Registered .ubs extension.', mtInformation, [mbOK], 0)
      else
        MessageDlg('Could not register .ubs extension.', mtError, [mbOK], 0);
    epDifferentProgram:
      if MessageDlg('.ubs is already bound to a different program. Continue?', mtConfirmation, mbYesNo, 0) = mrYes then
      begin
        if RegisterExtension('.ubs', 'UBS-Explorer', 'Unbound-Storage') then
          MessageDlg('Registered .ubs extension.', mtInformation, [mbOK], 0)
        else
          MessageDlg('Could not register .ubs extension.', mtError, [mbOK], 0);
      end;
    epExists:
      if UnregisterExtension('.ubs') then
        MessageDlg('Unregistered .ubs extension.', mtInformation, [mbOK], 0)
      else
        MessageDlg('Could not unregister .ubs extension.', mtError, [mbOK], 0);
  end;
end;

procedure TfrmMain.actRegisterExtensionUpdate(Sender: TObject);
begin
  actRegisterExtension.Checked := ExtensionRegistered('.ubs') = epExists;
end;

procedure TfrmMain.actSaveAllExecute(Sender: TObject);
var
  I: Integer;
  Tab: TfrmTab;
begin
  for I := 0 to pcTabs.PageCount - 1 do
  begin
    Tab := pcTabs.Pages[I].Controls[0] as TfrmTab;
    if not Tab.Saved then
      Tab.Save;
  end;
end;

procedure TfrmMain.actSaveAllUpdate(Sender: TObject);
var
  ActionEnabled: Boolean;
  I: Integer;
begin
  ActionEnabled := False;
  for I := 0 to pcTabs.PageCount - 1 do
  begin
    if not(pcTabs.Pages[I].Controls[0] as TfrmTab).Saved then
      ActionEnabled := True;
  end;
  actSaveAll.Enabled := ActionEnabled;
  actSaveAll.Checked := HasTab and not ActionEnabled;
end;

procedure TfrmMain.actSaveAsExecute(Sender: TObject);
begin
  ActiveTab.SaveAs;
end;

procedure TfrmMain.actSaveAsUpdate(Sender: TObject);
begin
  actSaveAs.Enabled := HasTab;
end;

procedure TfrmMain.actSaveExecute(Sender: TObject);
begin
  if ActiveTab.Filename.IsEmpty then
    actSaveAsExecute(Sender)
  else
    ActiveTab.Save;
end;

procedure TfrmMain.actSaveUpdate(Sender: TObject);
begin
  actSave.Enabled := HasTab and not ActiveTab.Saved;
  actSave.Checked := HasTab and ActiveTab.Saved;
end;

procedure TfrmMain.aeEventsActivate(Sender: TObject);
begin
  if HasTab then
    ActiveTab.CheckFileChanged;
end;

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  while CanClose and HasTab do
    CanClose := ActiveTab.TryClose;
end;

procedure TfrmMain.pcTabsChange(Sender: TObject);
begin
  if HasTab then
    ActiveTab.CheckFileChanged;
end;

procedure TfrmMain.pcTabsMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  TabIndex: Integer;
begin
  if Button = mbMiddle then
  begin
    TabIndex := pcTabs.IndexOfTabAt(X, Y);
    if TabIndex <> -1 then
      (pcTabs.Pages[TabIndex].Controls[0] as TfrmTab).TryClose;
  end;
end;

procedure TfrmMain.WMDropFiles(var Msg: TWMDropFiles);
var
  FileCount, I, BufferSize: Cardinal;
  Filename, ErrorMessage: string;
  InvalidFiles: IList<string>;
begin
  InvalidFiles := TList<string>.Create;
  FileCount := DragQueryFile(Msg.Drop, $FFFFFFFF, nil, 0);
  I := 0;
  while I < FileCount do
  begin
    BufferSize := DragQueryFile(Msg.Drop, I, nil, 0) + 1;
    SetLength(Filename, BufferSize);
    DragQueryFile(Msg.Drop, I, @Filename[1], BufferSize);
    SetLength(Filename, BufferSize - 1);

    try
      OpenTab(Filename);
    except
      InvalidFiles.Add(Filename);
    end;
    Inc(I);
  end;
  DragFinish(Msg.Drop);

  if not InvalidFiles.Empty then
  begin
    if InvalidFiles.Count = 1 then
      ErrorMessage := 'Could not open file:'
    else
      ErrorMessage := Format('Could not open %d files:', [InvalidFiles.Count]);
    for Filename in InvalidFiles do
      ErrorMessage := ErrorMessage + sLineBreak + Filename;
    MessageDlg(ErrorMessage, mtError, [mbOK], 0);
  end;
end;

procedure TfrmMain.OpenTab(AFilename: string);
var
  TabIndex: Integer;
  ExplorerTab: TfrmTab;
  NewTab: TTabSheet;
  TabFrame: TfrmTab;
begin
  for TabIndex := 0 to pcTabs.PageCount - 1 do
  begin
    ExplorerTab := pcTabs.Pages[TabIndex].Controls[0] as TfrmTab;
    if ExplorerTab.Filename = AFilename then
    begin
      pcTabs.ActivePageIndex := TabIndex;
      Exit;
    end;
  end;
  NewTab := TTabSheet.Create(Self);
  NewTab.PageControl := pcTabs;
  try
    TabFrame := TfrmTab.Create(NewTab, AFilename);
  except
    NewTab.Free;
    raise;
  end;
  TabFrame.Parent := NewTab;
  TabFrame.Align := alClient;
  TabFrame.AlignWithMargins := True;
  TabFrame.OnFilenameChange.Add(FilenameChange);
  TabFrame.OnModifiedChange.Add(ModifiedChange);
  UpdateCaption(TabFrame);
  NewTab.ImageIndex := Ord(TabFrame.UBSValue.GetTag);
  pcTabs.ActivePage := NewTab;
end;

procedure TfrmMain.OpenNew(AUBSTag: TUBSTag);
var
  NewTab: TTabSheet;
  TabFrame: TfrmTab;
begin
  NewTab := TTabSheet.Create(Self);
  NewTab.PageControl := pcTabs;
  TabFrame := TfrmTab.Create(NewTab, AUBSTag);
  TabFrame.Parent := NewTab;
  TabFrame.Align := alClient;
  TabFrame.AlignWithMargins := True;
  TabFrame.OnFilenameChange.Add(FilenameChange);
  UpdateCaption(TabFrame);
  NewTab.ImageIndex := Ord(AUBSTag);
  pcTabs.ActivePage := NewTab;
end;

function TfrmMain.GetActiveTab: TfrmTab;
begin
  if not HasTab then
    Exit(nil);
  Result := pcTabs.ActivePage.Controls[0] as TfrmTab;
end;

procedure TfrmMain.FilenameChange(const ATab: TfrmTab);
begin
  UpdateCaption(ATab);
end;

function TfrmMain.HasTab: Boolean;
begin
  Result := pcTabs.ActivePage <> nil;
end;

procedure TfrmMain.ModifiedChange(const ATab: TfrmTab);
begin
  UpdateCaption(ATab);
end;

procedure TfrmMain.ToolButton1Click(Sender: TObject);
begin
  dlgEditValue.ShowModal;
end;

procedure TfrmMain.UpdateCaption(const ATab: TfrmTab);
var
  TabSheet: TTabSheet;
begin
  TabSheet := ATab.Parent as TTabSheet;
  if ATab.Filename.IsEmpty then
    TabSheet.Caption := 'new'
  else
    TabSheet.Caption := ChangeFileExt(ExtractFileName(ATab.Filename), '');
  if ATab.Modified then
    TabSheet.Caption := TabSheet.Caption + '*';
end;

end.
