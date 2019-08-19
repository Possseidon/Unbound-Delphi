unit Unbound.Game.Serialization;

interface

uses
  System.SysUtils,

  Pengine.ICollections,
  Pengine.IntMaths,
  Pengine.Vector,
  Pengine.Color;

type

  EUBSError = class(Exception);

  TUBSTag = (
    // Nil type
    ubsNil,

    // Basic/Nested structures
    ubsMap,
    ubsList,

    // Common Primitives
    ubsInteger,
    ubsSingle,
    ubsBoolean,
    ubsString,
    ubsByteArray,

    // Utility
    ubsGUID,

    // Integer math
    ubsIntBounds1,
    ubsIntBounds2,
    ubsIntBounds3,
    ubsIntVector2,
    ubsIntVector3,

    // Vector math
    ubsBounds1,
    ubsBounds2,
    ubsBounds3,
    ubsVector2,
    ubsVector3,

    // Color
    ubsColorRGB,
    ubsColorRGBA
    );

  TUBSValue = class
  public
    class function GetTag: TUBSTag; virtual; abstract;

    function Cast<T: TUBSValue>: T;

  end;

  TUBSNil = class(TUBSValue)
  public
    class function GetTag: TUBSTag; override;

  end;

  TUBSMap = class(TUBSValue)
  private
    FMap: IToObjectMap<string, TUBSValue>;
    FOrder: IList<TPair<string, TUBSValue>>;

    function GetMap: IReadonlyMap<string, TUBSValue>;
    function GetOrder: IReadonlyList<TPair<string, TUBSValue>>;

    function GetItem(AKey: string): TUBSValue;
    procedure SetItem(AKey: string; const Value: TUBSValue);

  public
    constructor Create;

    class function GetTag: TUBSTag; override;

    property Map: IReadonlyMap<string, TUBSValue> read GetMap;
    property Order: IReadonlyList < TPair < string, TUBSValue >> read GetOrder;

    property Items[AKey: string]: TUBSValue read GetItem write SetItem; default;

  end;

  TUBSList = class(TUBSValue)
  private
    FItems: IObjectList<TUBSValue>;

    function GetItem(AIndex: Integer): TUBSValue;
    procedure SetItem(AIndex: Integer; const Value: TUBSValue);

  public
    constructor Create;

    class function GetTag: TUBSTag; override;

    property Items[AIndex: Integer]: TUBSValue read GetItem write SetItem; default;
    procedure Add(AValue: TUBSValue);

    function GetEnumerator: IIterator<TUBSValue>;

  end;

  TUBSValue<T> = class(TUBSValue)
  private
    FValue: T;

  public
    property Value: T read FValue write FValue;

  end;

  TUBSInteger = class(TUBSValue<Integer>)
  public
    class function GetTag: TUBSTag; override;

  end;

  TUBSSingle = class(TUBSValue<Single>)
  public
    class function GetTag: TUBSTag; override;

  end;

  TUBSBoolean = class(TUBSValue<Boolean>)
  public
    class function GetTag: TUBSTag; override;

  end;

  TUBSString = class(TUBSValue<string>)
  public
    class function GetTag: TUBSTag; override;

  end;

  TUBSByteArray = class(TUBSValue)
  public
    class function GetTag: TUBSTag; override;

  end;

  TUBSGUID = class(TUBSValue<TGUID>)
  public
    class function GetTag: TUBSTag; override;

  end;

  TUBSIntBounds1 = class(TUBSValue<TIntBounds1>)
  public
    class function GetTag: TUBSTag; override;

  end;

  TUBSIntBounds2 = class(TUBSValue<TIntBounds2>)
  public
    class function GetTag: TUBSTag; override;

  end;

  TUBSIntBounds3 = class(TUBSValue<TIntBounds3>)
  public
    class function GetTag: TUBSTag; override;

  end;

  TUBSIntVector2 = class(TUBSValue<TIntVector2>)
  public
    class function GetTag: TUBSTag; override;

  end;

  TUBSIntVector3 = class(TUBSValue<TIntVector3>)
  public
    class function GetTag: TUBSTag; override;

  end;

  TUBSBounds1 = class(TUBSValue<TBounds1>)
  public
    class function GetTag: TUBSTag; override;

  end;

  TUBSBounds2 = class(TUBSValue<TBounds2>)
  public
    class function GetTag: TUBSTag; override;

  end;

  TUBSBounds3 = class(TUBSValue<TBounds3>)
  public
    class function GetTag: TUBSTag; override;

  end;

  TUBSVector2 = class(TUBSValue<TVector2>)
  public
    class function GetTag: TUBSTag; override;

  end;

  TUBSVector3 = class(TUBSValue<TVector3>)
  public
    class function GetTag: TUBSTag; override;

  end;

  TUBSColorRGB = class(TUBSValue<TColorRGB>)
  public
    class function GetTag: TUBSTag; override;

  end;

  TUBSColorRGBA = class(TUBSValue<TColorRGBA>)
  public
    class function GetTag: TUBSTag; override;

  end;

  ISerializable = interface;

  TSerializer = class
  public type

    TMode = (
      smSerialize,
      smUnserialize
      );

  private
    FMode: TMode;
    FValue: TUBSMap;

  public
    class function Serialize(ASerializable: ISerializable): TUBSMap;
    class procedure Unserialize(ASerializable: ISerializable; AValue: TUBSMap);

    property Mode: TMode read FMode;
    property Value: TUBSMap read FValue;

    procedure Define(AName: string; ASerializable: ISerializable);
    procedure DefineList<T: ISerializable>(AName: string; ACollection: ICollection<T>; AInstantiator: TFunc<T>);
    // TODO: All the other defines

  end;

  ISerializable = interface
    procedure Serialize(ASerializer: TSerializer);

  end;

implementation

{ TUBSNil }

class function TUBSNil.GetTag: TUBSTag;
begin
  Result := ubsNil;
end;

{ TUBSMap }

function TUBSMap.GetMap: IReadonlyMap<string, TUBSValue>;
begin
  Result := FMap.ReadonlyMap;
end;

function TUBSMap.GetOrder: IReadonlyList<TPair<string, TUBSValue>>;
begin
  Result := FOrder.ReadonlyList;
end;

function TUBSMap.GetItem(AKey: string): TUBSValue;
begin
  Result := FMap[AKey];
end;

procedure TUBSMap.SetItem(AKey: string; const Value: TUBSValue);
begin
  if FMap.ContainsKey(AKey) then
    raise EUBSError.Create('UBS-Key exists already.');
  FMap[AKey] := Value;
  FOrder.Add(TPair<string, TUBSValue>.Create(AKey, Value));
end;

constructor TUBSMap.Create;
begin
  FMap := TToObjectMap<string, TUBSValue>.Create;
  FOrder := TList < TPair < string, TUBSValue >>.Create;
end;

class function TUBSMap.GetTag: TUBSTag;
begin
  Result := ubsMap;
end;

{ IUBSList }

function TUBSList.GetItem(AIndex: Integer): TUBSValue;
begin
  Result := FItems[AIndex];
end;

procedure TUBSList.SetItem(AIndex: Integer; const Value: TUBSValue);
begin
  FItems[AIndex] := Value;
end;

constructor TUBSList.Create;
begin
  FItems := TObjectList<TUBSValue>.Create;
end;

class function TUBSList.GetTag: TUBSTag;
begin
  Result := ubsList;
end;

procedure TUBSList.Add(AValue: TUBSValue);
begin
  FItems.Add(AValue);
end;

function TUBSList.GetEnumerator: IIterator<TUBSValue>;
begin
  Result := FItems.GetEnumerator;
end;

{ TUBSInteger }

class function TUBSInteger.GetTag: TUBSTag;
begin
  Result := ubsInteger;
end;

{ TUBSSingle }

class function TUBSSingle.GetTag: TUBSTag;
begin
  Result := ubsSingle;
end;

{ TUBSBoolean }

class function TUBSBoolean.GetTag: TUBSTag;
begin
  Result := ubsBoolean;
end;

{ TUBSString }

class function TUBSString.GetTag: TUBSTag;
begin
  Result := ubsString;
end;

{ TUBSByteArray }

class function TUBSByteArray.GetTag: TUBSTag;
begin
  Result := ubsByteArray;
end;

{ TUBSGUID }

class function TUBSGUID.GetTag: TUBSTag;
begin
  Result := ubsGUID;
end;

{ TUBSIntBounds1 }

class function TUBSIntBounds1.GetTag: TUBSTag;
begin
  Result := ubsIntBounds1;
end;

{ TUBSIntBounds2 }

class function TUBSIntBounds2.GetTag: TUBSTag;
begin
  Result := ubsIntBounds2;
end;

{ TUBSIntBounds3 }

class function TUBSIntBounds3.GetTag: TUBSTag;
begin
  Result := ubsIntBounds3;
end;

{ TUBSIntVector2 }

class function TUBSIntVector2.GetTag: TUBSTag;
begin
  Result := ubsIntVector2;
end;

{ TUBSIntVector3 }

class function TUBSIntVector3.GetTag: TUBSTag;
begin
  Result := ubsIntVector3;
end;

{ TUBSBounds1 }

class function TUBSBounds1.GetTag: TUBSTag;
begin
  Result := ubsBounds1;
end;

{ TUBSBounds2 }

class function TUBSBounds2.GetTag: TUBSTag;
begin
  Result := ubsBounds2;
end;

{ TUBSBounds3 }

class function TUBSBounds3.GetTag: TUBSTag;
begin
  Result := ubsBounds3;
end;

{ TUBSVector2 }

class function TUBSVector2.GetTag: TUBSTag;
begin
  Result := ubsVector2;
end;

{ TUBSVector3 }

class function TUBSVector3.GetTag: TUBSTag;
begin
  Result := ubsVector3;
end;

{ TUBSColorRGB }

class function TUBSColorRGB.GetTag: TUBSTag;
begin
  Result := ubsColorRGB;
end;

{ TUBSColorRGBA }

class function TUBSColorRGBA.GetTag: TUBSTag;
begin
  Result := ubsColorRGBA;
end;

{ TSerializer }

procedure TSerializer.Define(AName: string; ASerializable: ISerializable);
begin
  case Mode of
    smSerialize:
      Value[AName] := Serialize(ASerializable);
    smUnserialize:
      Unserialize(ASerializable, Value[AName].Cast<TUBSMap>);
  end;
end;

procedure TSerializer.DefineList<T>(AName: string; ACollection: ICollection<T>; AInstantiator: TFunc<T>);
var
  List: TUBSList;
  Item: T;
  UBSValue: TUBSValue;
begin
  case Mode of
    smSerialize:
      begin
        List := TUBSList.Create;
        for Item in ACollection do
          List.Add(Serialize(Item));
        Value[AName] := List;
      end;
    smUnserialize:
      begin
        ACollection.Clear;
        for UBSValue in Value[AName].Cast<TUBSList> do
        begin
          Item := AInstantiator;
          Unserialize(Item, UBSValue.Cast<TUBSMap>);
          ACollection.Add(Item);
        end;
      end;
  end;
end;

class function TSerializer.Serialize(ASerializable: ISerializable): TUBSMap;
var
  Serializer: TSerializer;
begin
  Serializer := TSerializer.Create;
  Serializer.FMode := smSerialize;
  Serializer.FValue := TUBSMap.Create;
  try
    ASerializable.Serialize(Serializer);
    Result := Serializer.FValue;
  finally
    Serializer.Free;
  end;
end;

class procedure TSerializer.Unserialize(ASerializable: ISerializable; AValue: TUBSMap);
var
  Serializer: TSerializer;
begin
  Serializer := TSerializer.Create;
  Serializer.FMode := smUnserialize;
  Serializer.FValue := AValue;
  try
    ASerializable.Serialize(Serializer);
  finally
    Serializer.FValue.Free;
    Serializer.Free;
  end;
end;

{ TUBSValue }

function TUBSValue.Cast<T>: T;
begin
  if Self.ClassType = T then
    Exit(T(Self));
  raise EUBSError.Create('Invalid cast of UBS-Type.');
end;

end.
