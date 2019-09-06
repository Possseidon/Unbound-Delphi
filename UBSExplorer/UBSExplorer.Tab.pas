unit UBSExplorer.Tab;

interface

uses
  System.SysUtils,
  System.IOUtils,
  System.Classes,
  System.UITypes,
  System.Types,

  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.Controls,
  Vcl.ComCtrls,

  Pengine.EventHandling,
  Pengine.ICollections,

  Unbound.Game.Serialization,

  UBSExplorer.DataModule;

type

  TUBSTreeNode = class(TTreeNode)
  private
    FUBSParent: TUBSParent;
    FUBSValue: TUBSValue;
    FName: string;
    FIndex: Integer;
    procedure SetName(const Value: string);
    
  public
    procedure Initialize(AParentMap: TUBSMap; AName: string); overload;
    procedure Initialize(AParentList: TUBSList; AIndex: Integer); overload;

    property UBSParent: TUBSParent read FUBSParent;
    property UBSValue: TUBSValue read FUBSValue;
    property Name: string read FName write SetName;
    property Index: Integer read FIndex;

    function CanRename: Boolean;
    
    procedure UpdateDisplay;
    procedure UpdateChildren;

    class procedure GenerateChildren(ATreeView: TTreeView; AUBSValue: TUBSValue; AParent: TUBSTreeNode = nil);

  end;

  TfrmTab = class(TFrame)
    tvExplorer: TTreeView;
    procedure tvExplorerCreateNodeClass(Sender: TCustomTreeView; var NodeClass: TTreeNodeClass);
    procedure tvExplorerEditing(Sender: TObject; Node: TTreeNode; var AllowEdit: Boolean);
  private
    FFilename: string;
    FFileTimestamp: TDateTime;
    FUBSValue: TUBSValue;
    FModified: Boolean;
    FSaved: Boolean;
    FOnFilenameChange: TEvent<TfrmTab>;
    FOnModifiedChange: TEvent<TfrmTab>;

    function FindNewName(AMap: TUBSMap): string;

    function GetOnFilenameChange: TEvent<TfrmTab>.TAccess;

    procedure Modify;
    function GetOnModifiedChange: TEvent<TfrmTab>.TAccess;

    function GetSelectedUBSValue: TUBSValue;
    function GetSelectedUBSParent: TUBSParent;
    function GetSelectedValueNode: TUBSTreeNode;
    function GetSelectedParentNode: TUBSTreeNode;

  public
    constructor Create(AOwner: TComponent; AUBSTag: TUBSTag); reintroduce; overload;
    constructor Create(AOwner: TComponent; AFilename: string); reintroduce; overload;
    destructor Destroy; override;

    property Filename: string read FFilename;
    property UBSValue: TUBSValue read FUBSValue;
    property Modified: Boolean read FModified;
    property Saved: Boolean read FSaved;

    function FindNode(AValue: TUBSValue): TUBSTreeNode;

    property SelectedValueNode: TUBSTreeNode read GetSelectedValueNode;
    property SelectedParentNode: TUBSTreeNode read GetSelectedParentNode;

    property SelectedUBSValue: TUBSValue read GetSelectedUBSValue;
    property SelectedUBSParent: TUBSParent read GetSelectedUBSParent;

    procedure UpdateTreeView;

    function Save: Boolean;
    function SaveAs: Boolean;

    function FileChanged: Boolean;
    procedure CheckFileChanged;

    function TryClose: Boolean;

    function CanAddValue: Boolean;
    procedure AddValue; overload;
    procedure AddValue(ATag: TUBSTag); overload;

    property OnFilenameChange: TEvent<TfrmTab>.TAccess read GetOnFilenameChange;
    property OnModifiedChange: TEvent<TfrmTab>.TAccess read GetOnModifiedChange;

  end;

implementation

{$R *.dfm}

{ TUBSTreeNode }

procedure TUBSTreeNode.Initialize(AParentMap: TUBSMap; AName: string);
begin
  FUBSParent := AParentMap;
  FUBSValue := AParentMap[AName];
  FName := AName;
  UpdateDisplay;
  UpdateChildren;
end;

procedure TUBSTreeNode.Initialize(AParentList: TUBSList; AIndex: Integer);
begin
  FUBSParent := AParentList;
  FUBSValue := AParentList[AIndex];
  FIndex := AIndex;
  UpdateDisplay;
  UpdateChildren;
end;

procedure TUBSTreeNode.SetName(const Value: string);
var
  Map: TUBSMap;
begin
  if Name = Value then
    Exit;
  Map := FUBSParent as TUBSMap;
  Map[Value] := Map.Extract(Name);
  FName := Value;
end;

procedure TUBSTreeNode.UpdateDisplay;
begin
  if (UBSValue = nil) or (UBSParent = nil) then
  begin
    ImageIndex := -1;
    Text := '<ERROR>';
    Exit;
  end;

  ImageIndex := Ord(UBSValue.GetTag);
  SelectedIndex := ImageIndex;
  Text := UBSValue.Format(ufInline);
  case UBSParent.GetTag of
    utList:
      Text := Format('[%d]: %s', [Index, Text]);
    utMap:
      Text := Format('%s: %s', [Name, Text]);
  else
    Text := Format('???: %s', [Text]);
  end;
end;

procedure TUBSTreeNode.UpdateChildren;
begin
  GenerateChildren(TTreeView(TreeView), UBSValue, Self);
end;

function TUBSTreeNode.CanRename: Boolean;
begin
  Result := UBSParent is TUBSMap;
end;

class procedure TUBSTreeNode.GenerateChildren(ATreeView: TTreeView; AUBSValue: TUBSValue; AParent: TUBSTreeNode);
var
  NewNode: TUBSTreeNode;
  Pair: TPair<string, TUBSValue>;
  I: Integer;
begin
  case AUBSValue.GetTag of
    utMap:
      for Pair in TUBSMap(AUBSValue).Order do
      begin
        NewNode := TTreeView(ATreeView).Items.AddChild(AParent, '') as TUBSTreeNode;
        NewNode.Initialize(TUBSMap(AUBSValue), Pair.Key);
      end;
    utList:
      for I := 0 to TUBSList(AUBSValue).Items.MaxIndex do
      begin
        NewNode := TTreeView(ATreeView).Items.AddChild(AParent, '') as TUBSTreeNode;
        NewNode.Initialize(TUBSList(AUBSValue), I);
      end;
  end;
end;

{ TfrmTab }

procedure TfrmTab.tvExplorerCreateNodeClass(Sender: TCustomTreeView; var NodeClass: TTreeNodeClass);
begin
  NodeClass := TUBSTreeNode;
end;

function TfrmTab.GetOnFilenameChange: TEvent<TfrmTab>.TAccess;
begin
  Result := FOnFilenameChange.Access;
end;

procedure TfrmTab.Modify;
begin
  FModified := True;
  FOnModifiedChange.Execute(Self);
end;

function TfrmTab.GetOnModifiedChange: TEvent<TfrmTab>.TAccess;
begin
  Result := FOnModifiedChange.Access;
end;

function TfrmTab.GetSelectedUBSValue: TUBSValue;
var
  SelectedNode: TUBSTreeNode;
begin
  SelectedNode := tvExplorer.Selected as TUBSTreeNode;
  if SelectedNode = nil then
    Exit(nil);
  Result := SelectedNode.UBSValue;
end;

function TfrmTab.GetSelectedUBSParent: TUBSParent;
var
  Node: TUBSTreeNode;
begin
  Node := SelectedParentNode;
  if Node = nil then
  begin
    if UBSValue is TUBSParent then
      Exit(TUBSParent(UBSValue));
    Exit(nil);
  end;
  Exit(TUBSParent(Node.UBSValue));
end;

function TfrmTab.GetSelectedValueNode: TUBSTreeNode;
begin
  Result := tvExplorer.Selected as TUBSTreeNode;
end;

function TfrmTab.GetSelectedParentNode: TUBSTreeNode;
begin
  Result := SelectedValueNode;
  if Result = nil then
    Exit;
  if Result.UBSValue is TUBSParent then
    Exit;
  if Result.Parent <> nil then
    Result := Result.Parent as TUBSTreeNode;
  if Result.UBSValue is TUBSParent then
    Exit;
  Result := nil;
end;

constructor TfrmTab.Create(AOwner: TComponent; AUBSTag: TUBSTag);
begin
  inherited Create(AOwner);
  FUBSValue := UBSClasses[AUBSTag].Create;
  UpdateTreeView;
end;

constructor TfrmTab.Create(AOwner: TComponent; AFilename: string);
begin
  inherited Create(AOwner);
  if not TFile.Exists(AFilename) then
    raise Exception.Create('File not found.');
  FSaved := True;
  FFilename := AFilename;
  FFileTimestamp := TFile.GetLastWriteTime(AFilename);
  FUBSValue := TUBSValue.LoadFromFile(AFilename);
  UpdateTreeView;
end;

destructor TfrmTab.Destroy;
begin
  FUBSValue.Free;
  inherited;
end;

function TfrmTab.FindNewName(AMap: TUBSMap): string;
const
  DefaultName = 'Unnamed';
var
  I: Integer;
begin
  Result := DefaultName;
  I := 0;
  while AMap.Map.ContainsKey(Result) do
  begin
    Inc(I);
    Result := Format('%s%d', [DefaultName, I]);
  end;
end;

function TfrmTab.FindNode(AValue: TUBSValue): TUBSTreeNode;
var
  Node: TTreeNode;
begin
  for Node in tvExplorer.Items do
    if (Node as TUBSTreeNode).UBSValue = AValue then
      Exit(TUBSTreeNode(Node));
  Result := nil;
end;

procedure TfrmTab.UpdateTreeView;
begin
  tvExplorer.Items.BeginUpdate;
  try
    tvExplorer.Items.Clear;                     
    TUBSTreeNode.GenerateChildren(tvExplorer, UBSValue);
  finally
    tvExplorer.Items.EndUpdate;
  end;
end;

function TfrmTab.Save: Boolean;
begin
  if Filename.IsEmpty then
    if not SaveAs then
      Exit(False);
  Result := True;
  UBSValue.SaveToFile(Filename);
  FFileTimestamp := TFile.GetLastWriteTime(Filename);
  FModified := False;
  FOnModifiedChange.Execute(Self);
end;

function TfrmTab.SaveAs: Boolean;
begin
  (Parent as TTabSheet).PageControl.ActivePage := (Parent as TTabSheet);
  dmData.dlgSave.Filename := Filename;
  Result := dmData.dlgSave.Execute;
  if not Result then
    Exit;
  FFilename := dmData.dlgSave.Filename;
  FOnFilenameChange.Execute(Self);
  Result := Save;
end;

function TfrmTab.FileChanged: Boolean;
begin
  Result := not Filename.IsEmpty and (TFile.GetLastWriteTime(Filename) <> FFileTimestamp);
end;

procedure TfrmTab.CheckFileChanged;
begin
  if FileChanged and
    (MessageDlg('File contents changed. Do you want to reload?', mtConfirmation, mbYesNo, 0) = mrYes) then
  begin
    FUBSValue.Free;
    FUBSValue := TUBSValue.LoadFromFile(Filename);
  end;
end;

function TfrmTab.TryClose: Boolean;
begin
  Result := True;
  if Modified then
  begin
    case MessageDlg('Do you want to save your changes?', mtInformation, mbYesNoCancel, 0) of
      mrYes:
        Result := Save;
      mrCancel:
        Result := False;
    end;
  end;
  if Result then
    Parent.Free;
end;

function TfrmTab.CanAddValue: Boolean;
begin
  Result := SelectedUBSParent <> nil;
end;

procedure TfrmTab.AddValue;
begin

end;

procedure TfrmTab.AddValue(ATag: TUBSTag);
var
  Node, NewNode: TUBSTreeNode;
  UBSParent: TUBSParent;
  NewName: string;
  NewValue: TUBSValue;
begin
  Node := SelectedParentNode;
  UBSParent := SelectedUBSParent;
  if UBSParent is TUBSList then
  begin
    NewValue := TUBSValue.CreateTyped(ATag);
    TUBSList(UBSParent).Add(NewValue);
    NewNode := tvExplorer.Items.AddChild(Node, '...') as TUBSTreeNode;
    NewNode.Initialize(TUBSList(UBSParent), TUBSList(UBSParent).Items.MaxIndex);
  end
  else if UBSParent is TUBSMap then
  begin
    NewName := FindNewName(TUBSMap(UBSParent));
    NewValue := TUBSValue.CreateTyped(ATag);
    TUBSMap(UBSParent)[NewName] := NewValue;
    NewNode := tvExplorer.Items.AddChild(Node, NewName) as TUBSTreeNode;
    NewNode.Initialize(TUBSMap(Node.UBSValue), NewName);
  end;
end;

procedure TfrmTab.tvExplorerEditing(Sender: TObject; Node: TTreeNode; var AllowEdit: Boolean);
begin
  AllowEdit := (Node as TUBSTreeNode).CanRename;
end;

end.
