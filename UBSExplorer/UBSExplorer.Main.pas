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
  UBSExplorer.DataModule;

type

  TfrmMain = class(TForm)
    mmMain: TMainMenu;
    sbMain: TStatusBar;
    File1: TMenuItem;
    Exit1: TMenuItem;
    alMain: TActionList;
    tbMain: TToolBar;
    ToolButton1: TToolButton;
    New1: TMenuItem;
    Open1: TMenuItem;
    Save1: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    actOpen: TAction;
    actSave: TAction;
    actSaveAs: TAction;
    actExit: TAction;
    Save2: TMenuItem;
    actNewMap: TAction;
    actNewList: TAction;
    NewMap1: TMenuItem;
    NewList1: TMenuItem;
    N3: TMenuItem;
    Extension1: TMenuItem;
    actRegisterExtension: TAction;
    pcTabs: TPageControl;
    aeEvents: TApplicationEvents;
    actClose: TAction;
    Close1: TMenuItem;
    procedure actCloseExecute(Sender: TObject);
    procedure actCloseUpdate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure actExitExecute(Sender: TObject);
    procedure actNewListExecute(Sender: TObject);
    procedure actNewMapExecute(Sender: TObject);
    procedure actOpenExecute(Sender: TObject);
    procedure actRegisterExtensionExecute(Sender: TObject);
    procedure actRegisterExtensionUpdate(Sender: TObject);
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

    procedure FilenameChange(const ATab: TfrmTab);

  public
    function HasTab: Boolean;
    property ActiveTab: TfrmTab read GetActiveTab;

  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

uses UBSExplorer.EditValueDialog;


procedure TfrmMain.actCloseExecute(Sender: TObject);
begin
  ActiveTab.TryClose;
end;

procedure TfrmMain.actCloseUpdate(Sender: TObject);
begin
  actClose.Enabled := HasTab;
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
  OpenNew(ubsList);
end;

procedure TfrmMain.actNewMapExecute(Sender: TObject);
begin
  OpenNew(ubsMap);
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
  actSave.Enabled := HasTab and ActiveTab.Modified;
  actSave.Checked := HasTab and not ActiveTab.Modified;
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
      pcTabs.Pages[TabIndex].Free;
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
  FilenameChange(TabFrame);
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
  FilenameChange(TabFrame);
  pcTabs.ActivePage := NewTab;
end;

function TfrmMain.GetActiveTab: TfrmTab;
begin
  if not HasTab then
    Exit(nil);
  Result := pcTabs.ActivePage.Controls[0] as TfrmTab;
end;

procedure TfrmMain.FilenameChange(const ATab: TfrmTab);
var
  TabSheet: TTabSheet;
begin
  TabSheet := ATab.Parent as TTabSheet;
  if ATab.Filename.IsEmpty then
    TabSheet.Caption := 'New'
  else
    TabSheet.Caption := ChangeFileExt(ExtractFileName(ATab.Filename), '');
end;

function TfrmMain.HasTab: Boolean;
begin
  Result := pcTabs.ActivePage <> nil;
end;

procedure TfrmMain.ToolButton1Click(Sender: TObject);
begin
  dlgEditValue.ShowModal;
end;

end.
