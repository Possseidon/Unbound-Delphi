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
  object pcTabs: TPageControl
    AlignWithMargins = True
    Left = 3
    Top = 31
    Width = 558
    Height = 332
    Align = alClient
    Images = dmData.ilIcons
    TabOrder = 1
    OnChange = pcTabsChange
    OnMouseDown = pcTabsMouseDown
  end
  object tbMain: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 558
    Height = 22
    AutoSize = True
    DrawingStyle = dsGradient
    Images = dmData.ilIcons
    TabOrder = 2
    object ToolButton2: TToolButton
      Left = 0
      Top = 0
      Action = actAddMap
    end
    object ToolButton3: TToolButton
      Left = 23
      Top = 0
      Action = actAddList
    end
    object ToolButton1: TToolButton
      Left = 46
      Top = 0
      Action = actAddValue
    end
    object ToolButton4: TToolButton
      Left = 69
      Top = 0
      Width = 8
      Caption = 'ToolButton4'
      ImageIndex = 8
      Style = tbsSeparator
    end
    object ToolButton5: TToolButton
      Left = 77
      Top = 0
      Action = actDeleteValue
    end
  end
  object mmMain: TMainMenu
    Images = dmData.ilIcons
    Left = 24
    Top = 48
    object File1: TMenuItem
      Caption = 'File'
      object miNew: TMenuItem
        Caption = 'New'
        object miNewMap: TMenuItem
          Action = actNewMap
        end
        object miNewList: TMenuItem
          Action = actNewList
        end
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object miOpen: TMenuItem
        Action = actOpen
      end
      object miSave: TMenuItem
        Action = actSave
      end
      object miSaveAs: TMenuItem
        Action = actSaveAs
        ShortCut = 41043
      end
      object miSaveAll: TMenuItem
        Action = actSaveAll
      end
      object miClose: TMenuItem
        Action = actClose
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object miExit: TMenuItem
        Action = actExit
      end
    end
    object miEdit: TMenuItem
      Caption = 'Edit'
      object miAddMap: TMenuItem
        Action = actAddMap
      end
      object miAddList: TMenuItem
        Action = actAddList
      end
      object miAddValue: TMenuItem
        Action = actAddValue
      end
      object N4: TMenuItem
        Caption = '-'
      end
      object miModifyValue: TMenuItem
        Action = actEditValue
      end
      object actRenameValue1: TMenuItem
        Action = actRenameValue
      end
      object miDelete: TMenuItem
        Action = actDeleteValue
        ShortCut = 46
      end
      object N6: TMenuItem
        Caption = '-'
      end
      object miMoveUp: TMenuItem
        Action = actMoveUp
      end
      object miMoveDown: TMenuItem
        Action = actMoveDown
      end
      object N5: TMenuItem
        Caption = '-'
      end
      object miFind: TMenuItem
        Action = actFind
      end
      object miFindNext: TMenuItem
        Action = actFindNext
      end
    end
    object miTools: TMenuItem
      Caption = 'Tools'
      object miDarkTheme: TMenuItem
        Action = actDarkTheme
      end
      object miRegsiterExtension: TMenuItem
        Action = actRegisterExtension
      end
      object N7: TMenuItem
        Caption = '-'
      end
      object miSettings: TMenuItem
        Action = actSettings
      end
    end
    object miHelp: TMenuItem
      Caption = 'Help'
      object miAbout: TMenuItem
        Action = actAbout
      end
    end
  end
  object alMain: TActionList
    Images = dmData.ilIcons
    Left = 72
    Top = 48
    object actOpen: TAction
      Category = 'File'
      Caption = 'Open...'
      ShortCut = 16463
      OnExecute = actOpenExecute
    end
    object actSave: TAction
      Category = 'File'
      Caption = 'Save'
      ShortCut = 16467
      OnExecute = actSaveExecute
      OnUpdate = actSaveUpdate
    end
    object actSaveAs: TAction
      Category = 'File'
      Caption = 'Save as...'
      ShortCut = 24659
      OnExecute = actSaveAsExecute
      OnUpdate = actSaveAsUpdate
    end
    object actExit: TAction
      Category = 'File'
      Caption = 'Exit'
      ImageIndex = 21
      ShortCut = 32883
      OnExecute = actExitExecute
    end
    object actNewMap: TAction
      Category = 'File'
      Caption = 'New Map'
      ImageIndex = 1
      ShortCut = 24653
      OnExecute = actNewMapExecute
    end
    object actNewList: TAction
      Category = 'File'
      Caption = 'New List'
      ImageIndex = 2
      ShortCut = 24652
      OnExecute = actNewListExecute
    end
    object actRegisterExtension: TAction
      Category = 'Tools'
      Caption = 'Register .ubs Extension'
      OnExecute = actRegisterExtensionExecute
      OnUpdate = actRegisterExtensionUpdate
    end
    object actClose: TAction
      Category = 'File'
      Caption = 'Close'
      ShortCut = 16471
      OnExecute = actCloseExecute
      OnUpdate = actCloseUpdate
    end
    object actAddMap: TAction
      Category = 'Edit'
      Caption = 'Add Map'
      ImageIndex = 1
      ShortCut = 16461
    end
    object actAbout: TAction
      Category = 'Help'
      Caption = 'About...'
      ShortCut = 112
    end
    object actAddList: TAction
      Category = 'Edit'
      Caption = 'Add List'
      ImageIndex = 2
      ShortCut = 16460
    end
    object actAddValue: TAction
      Category = 'Edit'
      Caption = 'Add Value...'
      ImageIndex = 7
      ShortCut = 16452
    end
    object actEditValue: TAction
      Category = 'Edit'
      Caption = 'Edit Value...'
      ImageIndex = 22
      SecondaryShortCuts.Strings = (
        'F2')
      ShortCut = 16453
    end
    object actRenameValue: TAction
      Category = 'Edit'
      Caption = 'Rename Value'
      ImageIndex = 22
      ShortCut = 16466
    end
    object actDeleteValue: TAction
      Category = 'Edit'
      Caption = 'Delete Value'
      ImageIndex = 21
    end
    object actFind: TAction
      Category = 'Edit'
      Caption = 'Find...'
      ShortCut = 16454
    end
    object actFindNext: TAction
      Category = 'Edit'
      Caption = 'Find Next'
      ShortCut = 114
    end
    object actMoveUp: TAction
      Category = 'Edit'
      Caption = 'Move Up'
      ShortCut = 16422
    end
    object actMoveDown: TAction
      Category = 'Edit'
      Caption = 'Move Down'
      ShortCut = 16424
    end
    object actSettings: TAction
      Category = 'File'
      Caption = 'Settings...'
    end
    object actDarkTheme: TAction
      Category = 'Tools'
      Caption = 'Dark Theme'
      OnExecute = actDarkThemeExecute
      OnUpdate = actDarkThemeUpdate
    end
    object actSaveAll: TAction
      Category = 'File'
      Caption = 'Save all'
      ShortCut = 24659
      OnExecute = actSaveAllExecute
      OnUpdate = actSaveAllUpdate
    end
  end
  object aeEvents: TApplicationEvents
    OnActivate = aeEventsActivate
    Left = 120
    Top = 48
  end
end
