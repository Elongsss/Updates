#region Variables
$site = "https://example" # Сайт для скачивания HTML файла
$parseword = "datetime" # Слово для парсинга строки из HTML файла
$messageParam = @{
    SmtpServer = "mail-test"
    From       = "$ENV:COMPUTERNAME@gmail"
    To         = 'ex.ample@gmail'
    Encoding   = "UTF8"
    Subject    = "Check Version $(get-date -format dd.MM.yyyy)"
    Body       = "Скрипт: $PSCommandPath"
}

$VerbosePreference = "Continue" 
#endregion

#region Main
Write-Verbose "Выполняется подключение к $site"

try {
    $temphtml = Invoke-WebRequest -Uri $site -TimeoutSec 60 | Select-String $parseword
}
catch {
        
    $messageParam.Body += "`nTimeout от $site`nТекст ошибки: $($_.Exception.Message)"
    Send-MailMessage @messageParam
    throw "Ошибка: $($_.Exception.Message)"
        
}
Write-Verbose "Начинается проверка страницы"

# Проверяем наличие текущей даты на странице.
if ($temphtml -match (Get-Date -Format "yyyy-MM-dd")) {
    $messageParam.Body += "`nОбнаружена новая версия"
    Send-MailMessage @messageParam
}
else {
    Write-Verbose "Новая версия не обнаружена"
}

#endregion