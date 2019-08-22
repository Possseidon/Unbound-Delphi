object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'UBS-Explorer'
  ClientHeight = 385
  ClientWidth = 564
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = mmMain
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object sbMain: TStatusBar
    Left = 0
    Top = 366
    Width = 564
    Height = 19
    Panels = <>
  end
  object tbMain: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 558
    Height = 22
    AutoSize = True
    DrawingStyle = dsGradient
    Images = ilIcons
    TabOrder = 1
    object ToolButton1: TToolButton
      Left = 0
      Top = 0
      Caption = 'ToolButton1'
      ImageIndex = 0
    end
  end
  object tcTabs: TTabControl
    AlignWithMargins = True
    Left = 3
    Top = 31
    Width = 558
    Height = 332
    Align = alClient
    TabOrder = 2
    object tvExplorer: TTreeView
      AlignWithMargins = True
      Left = 7
      Top = 9
      Width = 544
      Height = 316
      Align = alClient
      Images = ilIcons
      Indent = 19
      TabOrder = 0
      ExplicitLeft = 3
      ExplicitTop = 31
      ExplicitWidth = 558
      ExplicitHeight = 332
    end
  end
  object mmMain: TMainMenu
    Left = 16
    Top = 40
    object File1: TMenuItem
      Caption = 'File'
      object New1: TMenuItem
        Caption = 'New'
        object NewMap1: TMenuItem
          Action = actNewMap
        end
        object NewList1: TMenuItem
          Action = actNewList
        end
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object Open1: TMenuItem
        Action = actOpen
      end
      object Save2: TMenuItem
        Action = actSave
      end
      object Save1: TMenuItem
        Action = actSaveAs
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object Extension1: TMenuItem
        Action = actRegisterExtension
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object Exit1: TMenuItem
        Action = actExit
      end
    end
  end
  object alMain: TActionList
    Left = 64
    Top = 40
    object actOpen: TAction
      Category = 'File'
      Caption = 'Open...'
      OnExecute = actOpenExecute
    end
    object actSave: TAction
      Category = 'File'
      Caption = 'Save'
      OnExecute = actSaveExecute
    end
    object actSaveAs: TAction
      Category = 'File'
      Caption = 'Save as...'
      OnExecute = actSaveAsExecute
    end
    object actExit: TAction
      Category = 'File'
      Caption = 'Exit'
      OnExecute = actExitExecute
    end
    object actNewMap: TAction
      Category = 'File'
      Caption = 'New Map'
      OnExecute = actNewMapExecute
    end
    object actNewList: TAction
      Category = 'File'
      Caption = 'New List'
      OnExecute = actNewListExecute
    end
    object actRegisterExtension: TAction
      Category = 'File'
      Caption = 'Register .ubs Extension'
      OnExecute = actRegisterExtensionExecute
    end
  end
  object ilIcons: TImageList
    ColorDepth = cd32Bit
    DrawingStyle = dsTransparent
    Left = 112
    Top = 40
  end
end
