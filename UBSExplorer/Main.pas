unit Main;

interface

uses
  System.Actions,
  System.Classes,
  System.ImageList,
  System.SysUtils,
  System.IOUtils,
  System.UITypes,

  Vcl.ImgList,
  Vcl.Forms,
  Vcl.ActnList,
  Vcl.Menus,
  Vcl.Controls,
  Vcl.ComCtrls,
  Vcl.ToolWin,
  Vcl.Dialogs,

  Pengine.WinUtility,

  Unbound.Game.Serialization;

type

  TfrmMain = class(TForm)
    mmMain: TMainMenu;
    sbMain: TStatusBar;
    File1: TMenuItem;
    Exit1: TMenuItem;
    alMain: TActionList;
    tbMain: TToolBar;
    ToolButton1: TToolButton;
    ilIcons: TImageList;
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
    tcTabs: TTabControl;
    tvExplorer: TTreeView;
    N3: TMenuItem;
    Extension1: TMenuItem;
    actRegisterExtension: TAction;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure actExitExecute(Sender: TObject);
    procedure actNewListExecute(Sender: TObject);
    procedure actNewMapExecute(Sender: TObject);
    procedure actOpenExecute(Sender: TObject);
    procedure actRegisterExtensionExecute(Sender: TObject);
    procedure actSaveAsExecute(Sender: TObject);
    procedure actSaveExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    FUBSValue: TUBSValue;
    FFilename: string;
    FModified: Boolean;

    procedure SetUBSValue(const Value: TUBSValue);
    procedure SetFilename(const Value: string);

    procedure Load(AFilename: string);
    procedure Save(AFilename: string);

  public
    property UBSValue: TUBSValue read FUBSValue write SetUBSValue;
    property Filename: string read FFilename write SetFilename;

  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  actRegisterExtension.Checked := ExtensionExists('.ubs');
  case ParamCount of
    1:
      Load(ParamStr(1));
  end;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  FUBSValue.Free;
end;

procedure TfrmMain.Load(AFilename: string);
begin

end;

procedure TfrmMain.actExitExecute(Sender: TObject);
begin
  Close;
end;

procedure TfrmMain.actNewListExecute(Sender: TObject);
begin
  UBSValue := TUBSList.Create;
end;

procedure TfrmMain.actNewMapExecute(Sender: TObject);
begin
  UBSValue := TUBSMap.Create;
end;

procedure TfrmMain.actOpenExecute(Sender: TObject);
begin
  // TODO
end;

procedure TfrmMain.actRegisterExtensionExecute(Sender: TObject);
begin
  if ExtensionExists('.ubs') then
  begin
    if UnregisterExtension('.ubs') then
      MessageDlg('Unregistered .ubs extension.', mtInformation, [mbOK], 0)
    else
      MessageDlg('Could not unregister .ubs extension.', mtError, [mbOK], 0);
  end
  else
  begin
    if RegisterExtension('.ubs', 'UBS-Explorer', 'Unbound-Storage') then
      MessageDlg('Registered .ubs extension.', mtInformation, [mbOK], 0)
    else
      MessageDlg('Could not register .ubs extension.', mtError, [mbOK], 0);
  end;
  actRegisterExtension.Checked := ExtensionExists('.ubs');
end;

procedure TfrmMain.actSaveAsExecute(Sender: TObject);
begin
  // TODO
end;

procedure TfrmMain.actSaveExecute(Sender: TObject);
begin
  if Filename.IsEmpty then
    actSaveAsExecute(Sender);
end;

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if FModified then
  begin
    case MessageDlg('Do you want to save your changes?', mtInformation, mbYesNoCancel, 0) of
      mrYes:
        actSaveExecute(Sender);
      mrCancel:
        CanClose := False;
    end;
  end;
end;

procedure TfrmMain.Save(AFilename: string);
begin

end;

procedure TfrmMain.SetFilename(const Value: string);
begin
  FFilename := Value;
  Caption := 'UBS-Explorer - ' + Filename;
end;

procedure TfrmMain.SetUBSValue(const Value: TUBSValue);
begin
  FUBSValue.Free;
  FUBSValue := Value;
end;

end.
