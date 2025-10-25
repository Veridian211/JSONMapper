unit JSONMapper.AttributeHelper;

interface

uses
  System.Rtti;

type
  TCustomAttributeClass = class of TCustomAttribute;

  TRttiObjectHelper = class helper for TRttiObject
    function HasAttribute(AAttrClass: TCustomAttributeClass): Boolean; overload; inline;
    function HasAttribute<T: TCustomAttribute>: Boolean; overload; inline;
    function GetAttribute(AAttrClass: TCustomAttributeClass): TCustomAttribute; overload; inline;
    function GetAttribute<T: TCustomAttribute>: T; overload; inline;
  end;

implementation

function TRttiObjectHelper.GetAttribute(AAttrClass: TCustomAttributeClass): TCustomAttribute;
var
  attribute: TCustomAttribute;
begin
  for attribute in self.GetAttributes() do begin
    if attribute is AAttrClass then begin
      exit(attribute);
    end;
  end;
  exit(nil);
end;

function TRttiObjectHelper.GetAttribute<T>(): T;
var
  attribute: TCustomAttribute;
begin
  for attribute in self.GetAttributes() do begin
    if attribute is T then begin
      exit(T(attribute));
    end;
  end;
  exit(nil);
end;

function TRttiObjectHelper.HasAttribute(AAttrClass: TCustomAttributeClass): boolean;
var
  attribute: TCustomAttribute;
begin
  for attribute in self.GetAttributes() do begin
    if attribute is AAttrClass then begin
      exit(true);
    end;
  end;
  exit(false);
end;

function TRttiObjectHelper.HasAttribute<T>: Boolean;
var
  attribute: TCustomAttribute;
begin
  for attribute in self.GetAttributes() do begin
    if attribute is T then begin
      exit(true);
    end;
  end;
  exit(false);
end;

end.

