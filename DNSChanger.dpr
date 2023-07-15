program DNSChanger;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  WinApi.Windows, System.SysUtils, Registry, System.classes (*,
    WinApi.iphlpapi, WinApi.IpTypes*);

const
  NetCardsKey = '\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkCards';
  DNSArr: array [0 .. 5] of array [0 .. 2] of string = //
    ( //
    ('114', '114.114.114.114', '115.115.115.115'), //
    ('����', '223.5.5.5', '223.6.6.6'), //
    ('�ٶ�', '180.76.76.76', '8.8.8.8'), //
    ('��Ѷ', '119.29.29.29', '8.8.8.8'), //
    ('΢��', '4.1.1.1', '4.2.2.2'), //
    ('�ȸ�', '8.8.8.8', '8.8.4.4') //
    );

procedure GetNetCardKeys(NetCards: TStrings);
var
  Registry: TRegistry;
  SubKeyNames: TStringList;
  Name: string;
  ServiceName: string;
  Description: string;
begin
  NetCards.Clear;
  Registry := TRegistry.Create(KEY_READ or KEY_WRITE or KEY_WOW64_64KEY);
  Registry.RootKey := HKEY_LOCAL_MACHINE;
  Try
    // Registry.RootKey := RootKey;
    Registry.OpenKeyReadOnly(NetCardsKey);
    SubKeyNames := TStringList.Create;
    Try
      Registry.GetKeyNames(SubKeyNames);
      for Name in SubKeyNames do
      begin
        // Writeln(Name);
        Registry.OpenKeyReadOnly(NetCardsKey + '\' + Name);
        ServiceName := Registry.ReadString('ServiceName');
        Description := Registry.ReadString('Description');
        NetCards.Add(ServiceName + ' ' + Description);
        // Writeln(ServiceName);
        // Writeln(Description);
      end;
    Finally
      SubKeyNames.Free;
    End;
  Finally
    Registry.Free;
  End;
end;

(*
  procedure GetAdapterNames(AdapterNames: TStrings);
  var
  pAdapterList, pAdapter: PIP_ADAPTER_INFO;
  BufLen, Status: DWORD;
  I: Integer;
  begin
  AdapterNames.Clear;
  BufLen := 1024 * 15;
  GetMem(pAdapterList, BufLen);
  try
  repeat
  Status := GetAdaptersInfo(pAdapterList, BufLen);
  case Status of
  ERROR_SUCCESS:
  begin
  // some versions of Windows return ERROR_SUCCESS with
  // BufLen=0 instead of returning ERROR_NO_DATA as documented...
  if BufLen = 0 then
  begin
  raise Exception.Create
  ('No network adapter on the local computer.');
  end;
  Break;
  end;
  ERROR_NOT_SUPPORTED:
  begin
  raise Exception.Create
  ('GetAdaptersInfo is not supported by the operating system running on the local computer.');
  end;
  ERROR_NO_DATA:
  begin
  raise Exception.Create('No network adapter on the local computer.');
  end;
  ERROR_BUFFER_OVERFLOW:
  begin
  ReallocMem(pAdapterList, BufLen);
  end;
  else
  SetLastError(Status);
  RaiseLastOSError;
  end;
  until False;

  pAdapter := pAdapterList;
  while pAdapter <> nil do
  begin
  // if pAdapter^.AddressLength > 0 then
  // begin
  // for I := 0 to pAdapter^.AddressLength - 1 do begin
  // Result := Result + IntToHex(pAdapter^.Address[I], 2);
  // end;
  // Exit;
  // end;
  AdapterNames.Add(string(pAdapter.AdapterName) + ' ' +
  string(pAdapter.Description));
  pAdapter := pAdapter^.next;
  end;
  finally
  FreeMem(pAdapterList);
  end;
  end;

  const
  MAX_ADAPTER_NAME_LENGTH = 256;
  MAX_ADAPTER_DESCRIPTION_LENGTH = 128;
  MAX_ADAPTER_ADDRESS_LENGTH = 8;
  IPHelper = 'iphlpapi.dll';

  type
  USHORT = WORD;
  ULONG = DWORD;
  time_t = Longint;

  IP_ADDRESS_STRING = record
  S: array [0 .. 15] of Char;
  end;

  IP_MASK_STRING = IP_ADDRESS_STRING;
  PIP_MASK_STRING = ^IP_MASK_STRING;
  PIP_ADDR_STRING = ^IP_ADDR_STRING;

  IP_ADDR_STRING = record
  next: PIP_ADDR_STRING;
  IpAddress: IP_ADDRESS_STRING;
  IpMask: IP_MASK_STRING;
  Context: DWORD;
  end;

  PIP_ADAPTER_INFO = ^IP_ADAPTER_INFO;

  IP_ADAPTER_INFO = record
  next: PIP_ADAPTER_INFO;
  ComboIndex: DWORD;
  AdapterName: array [0 .. MAX_ADAPTER_NAME_LENGTH + 3] of AnsiChar;
  Description: array [0 .. MAX_ADAPTER_DESCRIPTION_LENGTH + 3] of AnsiChar;
  AddressLength: UINT;
  Address: array [0 .. MAX_ADAPTER_ADDRESS_LENGTH - 1] of BYTE;
  Index: DWORD;
  Type_: UINT;
  DhcpEnabled: UINT;
  CurrentIpAddress: PIP_ADDR_STRING;
  IpAddressList: IP_ADDR_STRING;
  GatewayList: IP_ADDR_STRING;
  DhcpServer: IP_ADDR_STRING;
  HaveWins: BOOL;
  PrimaryWinsServer: IP_ADDR_STRING;
  SecondaryWinsServer: IP_ADDR_STRING;
  LeaseObtained: time_t;
  LeaseExpires: time_t;
  end;

  function GetAdaptersInfo(pAdapterInfo: PIP_ADAPTER_INFO; var pOutBufLen: ULONG)
  : DWORD; stdcall; external IPHelper;

  function StringToWideString(const S: AnsiString): WideString;
  var
  InputLength, OutputLength: Integer;
  begin
  InputLength := Length(S);
  OutputLength := MultiByteToWideChar(CP_ACP, 0, PAnsiChar(S),
  InputLength, nil, 0);
  SetLength(Result, OutputLength);
  MultiByteToWideChar(CP_ACP, 0, PAnsiChar(S), InputLength, PWideChar(Result),
  OutputLength);
  end;

*)

function NotifyIPChange(lpszAdapterName: string): BOOL;
type
  TDhcpNotifyConfigChange = function(lpwszServerName: PWideChar; // ���ػ���ΪNULL
    lpwszAdapterName: PWideChar; // ����������
    bNewIpAddress: BOOL; // TRUE��ʾ����IP
    dwIpIndex: DWORD; // ָ���ڼ���IP��ַ�����ֻ�иýӿ�ֻ��һ��IP��ַ��Ϊ0
    dwIpAddress: DWORD; // IP��ַ
    dwSubNetMask: DWORD; // ��������
    nDhcpAction: Integer): BOOL; stdcall;
var
  hDhcpDll: DWORD;
  MyDhcpNotifyConfigChange: TDhcpNotifyConfigChange;
begin
  Result := False;
  hDhcpDll := LoadLibrary('dhcpcsvc.dll');
  if hDhcpDll <> 0 then
  begin
    MyDhcpNotifyConfigChange := GetProcAddress(hDhcpDll,
      'DhcpNotifyConfigChange');
    if Assigned(MyDhcpNotifyConfigChange) then
    begin
      MyDhcpNotifyConfigChange(nil, PChar(lpszAdapterName), False, 0, 0, 0, 0);
      Result := True;
    end;
    FreeLibrary(hDhcpDll);
  end;

end;

(*
  function RegIp(lpszAdapterName, pIPAddress, pNetMask, pNetGate, pDNSServer1,
  pDNSServer2: AnsiString): BOOL;
  var
  hkRoot: HKEY;
  mszDNSServer, mszIPAddress, mszNetMask, mszNetGate: AnsiString;
  strKeyName: AnsiString;
  begin
  strKeyName := 'SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\'
  + '{22195997-5DE8-480D-BB33-5C0D839481AA}'; // lpszAdapterName;
  if (RegOpenKeyEx(HKEY_LOCAL_MACHINE, PChar(strKeyName), 0,
  KEY_WRITE or KEY_WOW64_64KEY, hkRoot) <> ERROR_SUCCESS) then
  exit;
  mszDNSServer := pDNSServer1 + ',' + pDNSServer2;
  mszIPAddress := pIPAddress + #0#0;
  mszNetMask := pNetMask + #0#0;
  mszNetGate := pNetGate + #0#0;
  // RegSetValueEx(hkRoot, 'IPAddress', 0, REG_MULTI_SZ, PChar(mszIPAddress),
  // Length(mszIPAddress));
  // RegSetValueEx(hkRoot, 'SubnetMask', 0, REG_MULTI_SZ, PChar(mszNetMask),
  // Length(mszNetMask));
  // RegSetValueEx(hkRoot, 'DefaultGateway', 0, REG_MULTI_SZ, PChar(mszNetGate),
  // Length(mszNetGate));
  RegSetValueEx(hkRoot, 'NameServer', 0, REG_SZ, PChar(mszDNSServer),
  Length(mszDNSServer));
  RegCloseKey(hkRoot);
  end;
*)

procedure RegNameServer(AdapterName, DNS1, DNS2: string);
var
  Reg: TRegistry;
  KeyName: string;
begin
  KeyName := '\SYSTEM\ControlSet001\Services\Tcpip\Parameters\Interfaces\' +
    AdapterName; // {22195997-5de8-480d-bb33-5c0d839481aa}';
  Reg := TRegistry.Create(KEY_READ or KEY_WRITE or KEY_WOW64_64KEY);
  Reg.RootKey := HKEY_LOCAL_MACHINE;
  try
    if Reg.OpenKey(KeyName, True) then
    begin
      Reg.WriteString('NameServer', DNS1 + ',' + DNS2);
    end;

  finally
    Reg.Free;
  end;
end;

function ReadNameServer(AdapterName: string): string;
var
  Reg: TRegistry;
  KeyName: string;
begin
  KeyName := '\SYSTEM\ControlSet001\Services\Tcpip\Parameters\Interfaces\' +
    AdapterName; // {22195997-5de8-480d-bb33-5c0d839481aa}';
  Result := '';
  Reg := TRegistry.Create(KEY_READ or KEY_WOW64_64KEY);
  Reg.RootKey := HKEY_LOCAL_MACHINE;
  try
    if Reg.OpenKey(KeyName, True) then
    begin
      Result := Reg.ReadString('NameServer');
      if Result = '' then
      begin
        Result := 'AutoDNS';
      end;
    end;
  finally
    Reg.Free;
  end;
end;
(*
  function GetLanAdapterName: AnsiString;
  var
  InterfaceInfo, TmpPointer: PIP_ADAPTER_INFO;
  IP: PIP_ADDR_STRING;
  Len: ULONG;
  begin
  Result := '';
  if GetAdaptersInfo(nil, Len) = ERROR_BUFFER_OVERFLOW then
  begin
  GetMem(InterfaceInfo, Len);
  try
  if GetAdaptersInfo(InterfaceInfo, Len) = ERROR_SUCCESS then
  begin
  TmpPointer := InterfaceInfo;
  Result := String(TmpPointer.AdapterName) + ' ' +
  String(TmpPointer.Description);
  end;
  finally
  FreeMem(InterfaceInfo);
  end;
  end;
  end;

*)

var
  I, Index, IndexAdapter, IndexDNS: Integer;
  S: string;
  AdapterName: string;
  AdapterNames: TStrings;
  Quit, needMore: Boolean;

label
  lblWait, lblExit;

begin
  AdapterNames := TStringList.Create;
  try
    try

      Writeln('DNS�����������л� Version 1.0');
      (* ��ʼ���������� *)
      IndexAdapter := -1;
      (* ��ʼ��DNS���������� *)
      IndexDNS := -1;
      (* ��ȡ�����б� *)
      GetNetCardKeys(AdapterNames);

      if AdapterNames.Count = 0 then
      begin
        Writeln;
        Writeln('δ����������');
        goto lblWait;
      end
      else if AdapterNames.Count = 1 then
      begin
        AdapterName := AdapterNames[0];
        index := Pos(' ', AdapterName);
        Writeln;
        Writeln('����: ' + Copy(AdapterName, Index + 1, MaxInt) + ' - (' +
          ReadNameServer(Copy(AdapterName, 1, Index - 1)) + ')');
        IndexAdapter := 1;
      end
      else
      begin
        Writeln;
        Writeln('�����б�');
        I := 1;
        for AdapterName in AdapterNames do
        begin
          index := Pos(' ', AdapterName);
          Writeln(IntToStr(I) + '.' + Copy(AdapterName, Index + 1, MaxInt) +
            ' - (' + ReadNameServer(Copy(AdapterName, 1, Index - 1)) + ')');
          Inc(I);
        end;
        Writeln;

        Quit := False;
        needMore := True;

        while (not Quit) and needMore do
        begin

          Write('ѡ������(1-' + IntToStr(AdapterNames.Count) + ')�� �˳���Q��');
          ReadLn(S);
          Quit := (S = 'q') OR (S = 'Q');
          IndexAdapter := StrToIntDef(S, -1);
          needMore := (IndexAdapter <= 0) or
            (IndexAdapter > AdapterNames.Count);

        end;
        if Quit then
          goto lblExit;
      end;

      Writeln;
      Writeln('DNS��������');
      for I := 0 to Length(DNSArr) - 1 do
      begin
        Writeln(IntToStr(I + 1) + '.' + DNSArr[I][0] + ' - (' + DNSArr[I][1] + ','
          + DNSArr[I][2] + ')');
      end;
      Writeln;

      Quit := False;
      needMore := True;

      while (not Quit) and needMore do
      begin

        Write('ѡ��DNS������(1-' + IntToStr(Length(DNSArr)) + ')�� �˳���Q��');
        ReadLn(S);
        Quit := (S = 'q') OR (S = 'Q');
        IndexDNS := StrToIntDef(S, -1);
        needMore := (IndexDNS <= 0) or (IndexDNS > Length(DNSArr));

      end;

      if Quit then
        goto lblExit;

      Dec(IndexAdapter);
      Dec(IndexDNS);
      AdapterName := AdapterNames[IndexAdapter];
      index := Pos(' ', AdapterName);
      AdapterName := Copy(AdapterName, 1, Index - 1);
      RegNameServer(AdapterName, DNSArr[IndexDNS][1], DNSArr[IndexDNS][2]);
      NotifyIPChange(AdapterName);
      Writeln;
      Writeln('����: ' + Copy(AdapterNames[IndexAdapter], Index + 1, MaxInt));
      Writeln('DNS������: ' + DNSArr[IndexDNS][1] + ' ' + DNSArr[IndexDNS][2]);
      Writeln;

    lblWait:
      Writeln('���س����˳�');
      ReadLn;
    lblExit:
    except
      on E: Exception do
      begin
        Writeln(E.ClassName, ': ', E.Message);
      end;
    end;

  finally
    AdapterNames.Free;
  end;

end.
