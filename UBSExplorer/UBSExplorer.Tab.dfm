object frmTab: TfrmTab
  Left = 0
  Top = 0
  Width = 320
  Height = 240
  TabOrder = 0
  object tvExplorer: TTreeView
    Left = 0
    Top = 0
    Width = 320
    Height = 240
    Align = alClient
    Indent = 19
    ReadOnly = True
    TabOrder = 0
    OnCreateNodeClass = tvExplorerCreateNodeClass
    ExplicitTop = -3
  end
  object dlgSave: TSaveDialog
    DefaultExt = '.ubs'
    Filter = 'Unbound-Storage|.ubs'
    Left = 32
    Top = 16
  end
end
