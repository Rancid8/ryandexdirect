yadirGetClientParam <- function(Language = "ru", login = NULL, token = NULL){
  #�������� ������� ������ � ������
  if(is.null(login)|is.null(token)) {
    stop("You must enter login and API token!")
  }
  
  
  queryBody <- paste0("{
  \"method\": \"get\",
                      \"params\": { 
                      \"FieldNames\": [
                      \"AccountQuality\",
                      \"Archived\",
                      \"ClientId\",
                      \"ClientInfo\",
                      \"CountryId\",
                      \"CreatedAt\",
                      \"Currency\",
                      \"Grants\",
                      \"Login\",
                      \"Notification\",
                      \"OverdraftSumAvailable\",
                      \"Phone\",
                      \"Representatives\",
                      \"Restrictions\",
                      \"Settings\",
                      \"VatRate\"]
}
}")
  
  #�������� ������� �� ������
  answer <- POST("https://api.direct.yandex.com/json/v5/clients", body = queryBody, add_headers(Authorization = paste0("Bearer ",token), 'Accept-Language' = Language, "Client-Login" = login[1]))
  #�������� ���������� �� ������
  stop_for_status(answer)
  
  dataRaw <- content(answer, "parsed", "application/json")
  
  if(length(dataRaw$error) > 0){
    stop(paste0(dataRaw$error$error_string, " - ", dataRaw$error$error_detail))
  }
  
  #����������� ����� � data frame
  
  #������� ����������� ��������
    dictionary_df <- data.frame()
    
    for(dr in 1:length(dataRaw$result[[1]])){
      dictionary_df_temp <- data.frame(Login = dataRaw$result[[1]][[dr]]$Login,
                                       ClientId = dataRaw$result[[1]][[dr]]$ClientId,
                                       CountryId = dataRaw$result[[1]][[dr]]$CountryId,
                                       Currency = dataRaw$result[[1]][[dr]]$Currency,
                                       CreatedAt = dataRaw$result[[1]][[dr]]$CreatedAt,
                                       ClientInfo = dataRaw$result[[1]][[dr]]$ClientInfo,
                                       AccountQuality = dataRaw$result[[1]][[dr]]$AccountQuality,
                                       CampaignsTotalPerClient = dataRaw$result[[1]][[dr]]$Restrictions[[1]]$Value,
                                       CampaignsUnarchivePerClient = dataRaw$result[[1]][[dr]]$Restrictions[[2]]$Value,
                                       APIPoints = dataRaw$result[[1]][[dr]]$Restrictions[[10]]$Value)
      
      dictionary_df <- rbind(dictionary_df, dictionary_df_temp)
      
    }

    #������� ���������� � ������ ������� � � ���������� ������
    packageStartupMessage("���������� ������� ��������!", appendLF = T)
    packageStartupMessage(paste0("����� ������� � : " ,answer$headers$`units-used-login`), appendLF = T)
    packageStartupMessage(paste0("�-�� ������ �������������� ��� ���������� �������: " ,strsplit(answer$headers$units, "/")[[1]][1]), appendLF = T)
    packageStartupMessage(paste0("��������� ������� ��������� ������ ������: " ,strsplit(answer$headers$units, "/")[[1]][2]), appendLF = T)
    packageStartupMessage(paste0("�������� ����� ������: " ,strsplit(answer$headers$units, "/")[[1]][3]), appendLF = T)
    packageStartupMessage(paste0("���������� ������������� ������� ������� ���������� ��������� ��� ��������� � ������ ���������: ",answer$headers$requestid), appendLF = T)
    #���������� ��������� � ���� Data Frame
  return(dictionary_df)
}