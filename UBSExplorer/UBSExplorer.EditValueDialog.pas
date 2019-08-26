unit UBSExplorer.EditValueDialog;

interface

uses
  System.SysUtils,
  System.Classes,

  Winapi.Windows,

  Vcl.Graphics,
  Vcl.Forms,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.Buttons,
  Vcl.ComCtrls,
  Vcl.ExtCtrls,

  UBSExplorer.DataModule;

type
  TdlgEditValue = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    pcValueTypes: TPageControl;
    TabSheet1: TTabSheet;
    OKBtn: TButton;
    CancelBtn: TButton;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  dlgEditValue: TdlgEditValue;

implementation

{$R *.dfm}

end.
