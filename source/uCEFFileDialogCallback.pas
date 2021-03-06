// ************************************************************************
// ***************************** CEF4Delphi *******************************
// ************************************************************************
//
// CEF4Delphi is based on DCEF3 which uses CEF3 to embed a chromium-based
// browser in Delphi applications.
//
// The original license of DCEF3 still applies to CEF4Delphi.
//
// For more information about CEF4Delphi visit :
//         https://www.briskbard.com/index.php?lang=en&pageid=cef
//
//        Copyright � 2018 Salvador D�az Fau. All rights reserved.
//
// ************************************************************************
// ************ vvvv Original license and comments below vvvv *************
// ************************************************************************
(*
 *                       Delphi Chromium Embedded 3
 *
 * Usage allowed under the restrictions of the Lesser GNU General Public License
 * or alternatively the restrictions of the Mozilla Public License 1.1
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
 * the specific language governing rights and limitations under the License.
 *
 * Unit owner : Henri Gourvest <hgourvest@gmail.com>
 * Web site   : http://www.progdigy.com
 * Repository : http://code.google.com/p/delphichromiumembedded/
 * Group      : http://groups.google.com/group/delphichromiumembedded
 *
 * Embarcadero Technologies, Inc is not permitted to use or redistribute
 * this source code without explicit permission.
 *
 *)

unit uCEFFileDialogCallback;

{$IFNDEF CPUX64}
  {$ALIGN ON}
  {$MINENUMSIZE 4}
{$ENDIF}

{$I cef.inc}

interface

uses
  {$IFDEF DELPHI16_UP}
  System.Classes, System.SysUtils,
  {$ELSE}
  Classes, SysUtils,
  {$ENDIF}
  uCEFBaseRefCounted, uCEFInterfaces, uCEFTypes;

type
  TCefFileDialogCallbackRef = class(TCefBaseRefCountedRef, ICefFileDialogCallback)
  protected
    procedure Cont(selectedAcceptFilter: Integer; const filePaths: TStrings);
    procedure Cancel;
  public
    class function UnWrap(data: Pointer): ICefFileDialogCallback;
  end;

implementation

uses
  uCEFMiscFunctions, uCEFLibFunctions;

procedure TCefFileDialogCallbackRef.Cancel;
begin
  PCefFileDialogCallback(FData).cancel(FData);
end;

procedure TCefFileDialogCallbackRef.Cont(selectedAcceptFilter: Integer; const filePaths: TStrings);
var
  TempSL : TCefStringList;
  i : Integer;
  TempString : TCefString;
begin
  TempSL := nil;


  try
    try
      TempSL := cef_string_list_alloc;

      if (filePaths <> nil) and (filePaths.Count > 0) then
        for i := 0 to filePaths.Count - 1 do
          begin
            TempString := CefString(filePaths[i]);
            cef_string_list_append(TempSL, @TempString);
          end;

      PCefFileDialogCallback(FData).cont(PCefFileDialogCallback(FData), selectedAcceptFilter, TempSL);
    except
      on e : exception do
        if CustomExceptionHandler('TCefFileDialogCallbackRef.Cont', e) then raise;
    end;
  finally
    if (TempSL <> nil) then cef_string_list_free(TempSL);
  end;
end;

class function TCefFileDialogCallbackRef.UnWrap(data: Pointer): ICefFileDialogCallback;
begin
  if (data <> nil) then
    Result := Create(data) as ICefFileDialogCallback
   else
    Result := nil;
end;

end.
