unit Unbound.Game.Serialization;

interface

type

  TUBSTag = (
    ubsNil,
    ubsMap,
    ubsList,
    ubsInt,
    ubsFloat,
    ubsString
  );

  TUBSData = class

  end;

  TUBSNil = class

  end;

  TUBSMap = class

  end;

  TUBSList = class

  end;

  TUBSInt = class

  end;

  TUBSFloat = class

  end;

  TUBSString = class

  end;

  TSerializer = class;

  ISerializable = interface
    procedure Serialize(ASerializer: TSerializer);

  end;

  TSerializer = class
  public type

    TMode = (
      smSerialize,
      smUnserialize
    );

  private
    FMode: TMode;

  public
    constructor Create(AMode: TMode);

    class function Serialize(ASerializable: ISerializable): TUBSData;
    class procedure Unserialize(ASerializable: ISerializable; AUBSData: TUBSData);

    procedure Define(); overload;

  end;

implementation

end.

