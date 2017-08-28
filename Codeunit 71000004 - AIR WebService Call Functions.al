codeunit 71000004 "AIR WebService Call Functions"
{
    //https://www.kauffmann.nl/2017/06/24/al-support-for-rest-web-services/
    //https://github.com/ajkauffmann/ALWebServiceExamples/blob/master/BaseObjects/Codeunits/RESTWebServiceCode.al
    //https://github.com/ajkauffmann/ALWebServiceExamples/blob/master/BaseObjects/Codeunits/RESTWebServiceCode.al

    procedure CallWebService(var Arguments : Record "AIR WebService Argument") : Boolean
    var
        HttpClient : HttpClient;
        RequestMessage  : HttpRequestMessage;
        ResponseMessage : HttpResponseMessage;
        Content :HttpContent;
        AuthText:Text;
        TempBlob : Record TempBlob temporary;
    begin
        RequestMessage.Method := Format(Arguments.RestMethod);
        RequestMessage.SetRequestUri(Arguments.URL);

        if Arguments.UserName <> '' then 
        begin
          AuthText := StrSubstNo('%1:%2',Arguments.UserName,Arguments.Password);
          TempBlob.WriteAsText(AuthText,TextEncoding::Windows);
          HttpClient.DefaultRequestHeaders.Add('Authorization', StrSubstNo('Basic %1',TempBlob.ToBase64String()));
        end;      
        

        HttpClient.Send(RequestMessage,ResponseMessage);

        if not ResponseMessage.IsSuccessStatusCode then
            error('The web service returned an error message:\\' +
                  'Status code: %1\' +
                  'Description: %2',
                  ResponseMessage.HttpStatusCode,
                  ResponseMessage.ReasonPhrase);

        Content := ResponseMessage.Content;
        Arguments.SetResponseContent(Content);

        EXIT(ResponseMessage.IsSuccessStatusCode);
    end;

    procedure GetJsonToken(JsonObject:JsonObject;TokenKey:text)JsonToken:JsonToken;
    begin
        if not JsonObject.Get(TokenKey,JsonToken) then
            Error('Could not find a token with key %1',TokenKey);
    end;

        procedure SelectJsonToken(JsonObject:JsonObject;Path:text)JsonToken:JsonToken;
    begin
        if not JsonObject.SelectToken(Path,JsonToken) then
            Error('Could not find a token with path %1',Path);
    end;
}