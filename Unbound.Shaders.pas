unit Unbound.Shaders;

interface

uses
  Pengine.Vector,
  Pengine.Color,
  Pengine.GLProgram,
  Pengine.Skybox;

type

  TSkyboxShader = class(TSkyboxGLProgramBase)
  protected
    class procedure GetData(out AName: string; out AResource: Boolean); override;

  end;

  TTerrainShader = class(TGLProgramResource)
  public type

    TData = packed record
      Pos: TVector3;
      Color: TColorRGB;
    end;

  protected
    class function GetAttributeOrder: TGLProgram.TAttributeOrder; override;
    class procedure GetData(out AName: string; out AResource: Boolean); override;

  end;

  TDesignShader = class(TGLProgramResource)
  protected
    class function GetAttributeOrder: TGLProgram.TAttributeOrder; override;
    class procedure GetData(out AName: string; out AResource: Boolean); override;

  end;

  TEntityShader = class(TGLProgramResource)
  protected
    class function GetAttributeOrder: TGLProgram.TAttributeOrder; override;
    class procedure GetData(out AName: string; out AResource: Boolean); override;

  end;

implementation

{ TSkyboxShader }

class procedure TSkyboxShader.GetData(out AName: string; out AResource: Boolean);
begin
  AResource := False;
  if AResource then
    AName := 'SKYBOX'
  else
    AName := 'Data/Shader/skybox';
end;

{ TTerrainShader }

class function TTerrainShader.GetAttributeOrder: TGLProgram.TAttributeOrder;
begin
  Result := [
    'vpos',
    'vcolor'
    ];
end;

class procedure TTerrainShader.GetData(out AName: string; out AResource: Boolean);
begin
  AResource := False;
  if AResource then
    AName := 'TERRAIN'
  else
    AName := 'Data/Shader/terrain';
end;

{ TDesignShader }

class function TDesignShader.GetAttributeOrder: TGLProgram.TAttributeOrder;
begin
  Result := [];
end;

class procedure TDesignShader.GetData(out AName: string; out AResource: Boolean);
begin
  AResource := False;
  if AResource then
    AName := 'DESIGN'
  else
    AName := 'Data/Shader/design';
end;

{ TEntityShader }

class function TEntityShader.GetAttributeOrder: TGLProgram.TAttributeOrder;
begin
  Result := [];
end;

class procedure TEntityShader.GetData(out AName: string; out AResource: Boolean);
begin
  AResource := False;
  if AResource then
    AName := 'ENTITY'
  else
    AName := 'Data/Shader/entity';
end;

end.
