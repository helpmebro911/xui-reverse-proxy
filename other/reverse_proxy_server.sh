#!/usr/bin/env bash
# wget -N https://git && bash .sh d

###################################
### Standard values
###################################
export DEBIAN_FRONTEND=noninteractive
VERSION_MANAGER=1.4.0f
SECRET_PASSWORD="84ghrhhu43884hgHGrhguhure7!"
DEFAULT_FILE="/usr/local/reverse_proxy/reinstall_defaults.conf"
DB_PATH="/etc/x-ui/x-ui.db"
SCRIPT_URL="https://raw.githubusercontent.com/cortez24rus/xui-reverse-proxy/refs/heads/test/other/reverse_proxy_server.sh"

###################################
### Initialization and Declarations
###################################
declare -A defaults
declare -A args
declare -A regex
declare -A generate

###################################
### Regex Patterns for Validation
###################################
regex[domain]="^([a-zA-Z0-9-]+)\.([a-zA-Z0-9-]+\.[a-zA-Z]{2,})$"
regex[port]="^[1-9][0-9]*$"
regex[warp_license]="^[a-zA-Z0-9]{8}-[a-zA-Z0-9]{8}-[a-zA-Z0-9]{8}$"
regex[username]="^[a-zA-Z0-9]+$"
regex[ip]="^([0-9]{1,3}\.){3}[0-9]{1,3}$"
regex[tgbot_token]="^[0-9]{8,10}:[a-zA-Z0-9_-]{35}$"
regex[tgbot_admins]="^[a-zA-Z][a-zA-Z0-9_]{4,31}(,[a-zA-Z][a-zA-Z0-9_]{4,31})*$"
regex[domain_port]="^[a-zA-Z0-9]+([-.][a-zA-Z0-9]+)*\.[a-zA-Z]{2,}(:[1-9][0-9]*)?$"
regex[file_path]="^[a-zA-Z0-9_/.-]+$"
regex[url]="^(http|https)://([a-zA-Z0-9.-]+\.[a-zA-Z]{2,})(:[0-9]{1,5})?(/.*)?$"
generate[path]="tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 30"

###################################
### INFO
###################################
out_data()   { echo -e "\e[1;33m$1\033[0m \033[1;37m$2\033[0m"; }
tilda()      { echo -e "\033[31m\033[38;5;214m$*\033[0m"; }
warning()    { echo -e "\033[31m [!]\033[38;5;214m$*\033[0m"; }
error()      { echo -e "\033[31m\033[01m$*\033[0m"; exit 1; }
info()       { echo -e "\033[32m\033[01m$*\033[0m"; }
question()   { echo -e "\033[32m[?]\e[1;33m$*\033[0m"; }
hint()       { echo -e "\033[33m\033[01m$*\033[0m"; }
reading()    { read -rp " $(question "$1")" "$2"; }
text()       { eval echo "\${${L}[$*]}"; }
text_eval()  { eval echo "\$(eval echo "\${${L}[$*]}")"; }

###################################
### Languages
###################################
E[0]="Language:\n  1. English (default) \n  2. Русский"
R[0]="Язык:\n  1. English (по умолчанию) \n  2. Русский"
E[1]="Choose an action:"
R[1]="Выбери действие:"
E[2]="Error: this script requires superuser (root) privileges to run."
R[2]="Ошибка: для выполнения этого скрипта необходимы права суперпользователя (root)."
E[3]="Unable to determine IP address."
R[3]="Не удалось определить IP-адрес."
E[4]="Reinstalling script..."
R[4]="Повторная установка скрипта..."
E[5]="WARNING!"
R[5]="ВНИМАНИЕ!"
E[6]="It is recommended to perform the following actions before running the script"
R[6]="Перед запуском скрипта рекомендуется выполнить следующие действия"
E[7]="Annihilation of the system!"
R[7]="Аннигиляция системы!"
E[8]="Start the XRAY installation? Choose option [y/N]:"
R[8]="Начать установку XRAY? Выберите опцию [y/N]:"
E[9]="CANCEL"
R[9]="ОТМЕНА"
E[10]="\n|-----------------------------------------------------------------------------|\n"
R[10]="\n|-----------------------------------------------------------------------------|\n"
E[11]="Enter username:"
R[11]="Введите имя пользователя:"
E[12]="Enter user password:"
R[12]="Введите пароль пользователя:"
E[13]="Enter your domain name:"
R[13]="Введите ваше доменное имя:"
E[14]="Error: the entered address '$temp_value' is incorrectly formatted."
R[14]="Ошибка: введённый адрес '$temp_value' имеет неверный формат."
E[15]="Enter your email registered with Cloudflare:"
R[15]="Введите вашу почту, зарегистрированную на Cloudflare:"
E[16]="Enter your Cloudflare API token (Edit zone DNS) or global API key:"
R[16]="Введите ваш API токен Cloudflare (Edit zone DNS) или Cloudflare global API key:"
E[17]="Verifying domain, API token/key, and email..."
R[17]="Проверка домена, API токена/ключа и почты..."
E[18]="Error: invalid domain, API token/key, or email. Please try again."
R[18]="Ошибка: неправильно введён домен, API токен/ключ или почта. Попробуйте снова."
E[19]="Enter SNI for Reality (do not enter your domain):"
R[19]="Введите SNI для Reality (не вводите ваш домен):"
E[20]="Enter gRPC path:"
R[20]="Введите путь к gRPC:"
E[21]="Enter SplitHTTP path:"
R[21]="Введите путь к SplitHTTP:"
E[22]="Enter HTTPUpgrade path:"
R[22]="Введите путь к HTTPUpgrade:"
E[23]="Enter Websocket path:"
R[23]="Введите путь к Websocket:"
E[24]="Enter Node Exporter path:"
R[24]="Введите путь к Node Exporter:"
E[25]="Enter Adguard-home path:"
R[25]="Введите путь к Adguard-home:"
E[26]="Enter panel path:"
R[26]="Введите путь к панели:"
E[27]="Enter subscription path:"
R[27]="Введите путь к подписке:"
E[28]="Enter JSON subscription path:"
R[28]="Введите путь к JSON подписке:"
E[29]="Error: path cannot be empty, please re-enter."
R[29]="Ошибка: путь не может быть пустым, повторите ввод."
E[30]="Error: path must not contain characters {, }, /, $, \\, please re-enter."
R[30]="Ошибка: путь не должен содержать символы {, }, /, $, \\, повторите ввод."
E[31]="DNS server:\n  1. Systemd-resolved \n  2. Adguard-home"
R[31]="DNS сервер:\n  1. Systemd-resolved \n  2. Adguard-home"
E[32]="Systemd-resolved selected."
R[32]="Выбран systemd-resolved."
E[33]="Error: invalid choice, please try again."
R[33]="Ошибка: неверный выбор, попробуйте снова."
E[34]="Enter the Telegram bot token for the control panel:"
R[34]="Введите токен Telegram бота для панели управления:"
E[35]="Enter your Telegram ID:"
R[35]="Введите ваш Telegram ID:"
E[36]="Updating system and installing necessary packages."
R[36]="Обновление системы и установка необходимых пакетов."
E[37]="Configuring DNS."
R[37]="Настройка DNS."
E[38]="Download failed, retrying..."
R[38]="Скачивание не удалось, пробуем снова..."
E[39]="Adding user."
R[39]="Добавление пользователя."
E[40]="Enabling automatic security updates."
R[40]="Автоматическое обновление безопасности."
E[41]="Enabling BBR."
R[41]="Включение BBR."
E[42]="Disabling IPv6."
R[42]="Отключение IPv6."
E[43]="Configuring WARP."
R[43]="Настройка WARP."
E[44]="Issuing certificates."
R[44]="Выдача сертификатов."
E[45]="Configuring NGINX."
R[45]="Настройка NGINX."
E[46]="Setting up the panel for Xray."
R[46]="Настройка панели для Xray."
E[47]="Configuring UFW."
R[47]="Настройка UFW."
E[48]="Configuring SSH."
R[48]="Настройка SSH."
E[49]="Generate a key for your OS (ssh-keygen)."
R[49]="Сгенерируйте ключ для своей ОС (ssh-keygen)."
E[50]="In Windows, install the openSSH package and enter the command in PowerShell (recommended to research key generation online)."
R[50]="В Windows нужно установить пакет openSSH и ввести команду в PowerShell (рекомендуется изучить генерацию ключей в интернете)."
E[51]="If you are on Linux, you probably know what to do C:"
R[51]="Если у вас Linux, то вы сами все умеете C:"
E[52]="Command for Windows:"
R[52]="Команда для Windows:"
E[53]="Command for Linux:"
R[53]="Команда для Linux:"
E[54]="Configure SSH (optional step)? [y/N]:"
R[54]="Настроить SSH (необязательный шаг)? [y/N]:"
E[55]="Error: Keys not found. Please add them to the server before retrying..."
R[55]="Ошибка: ключи не найдены, добавьте его на сервер, прежде чем повторить..."
E[56]="Key found, proceeding with SSH setup."
R[56]="Ключ найден, настройка SSH."
E[57]="Installing bot."
R[57]="Установка бота."
E[58]="SAVE THIS SCREEN!"
R[58]="СОХРАНИ ЭТОТ ЭКРАН!"
E[59]="Access the panel at the link:"
R[59]="Доступ по ссылке к панели:"
E[60]="Quick subscription link for connection:"
R[60]="Быстрая ссылка на подписку для подключения:"
E[61]="Access Adguard-home at the link:"
R[61]="Доступ по ссылке к adguard-home:"
E[62]="SSH connection:"
R[62]="Подключение по SSH:"
E[63]="Username:"
R[63]="Имя пользователя:"
E[64]="Password:"
R[64]="Пароль:"
E[65]="Log file path:"
R[65]="Путь к лог файлу:"
E[66]="Prometheus monitor."
R[66]="Мониторинг Prometheus."
E[67]="Set up the Telegram bot? [y/N]:"
R[67]="Настроить telegram бота? [y/N]:"
E[68]="Bot:\n  1. IP limit (default) \n  2. Torrent ban"
R[68]="Бот:\n  1. IP limit (по умолчанию) \n  2. Torrent ban"
E[69]="Enter the Telegram bot token for IP limit, Torrent ban:"
R[69]="Введите токен Telegram бота для IP limit, Torrent ban:"
E[70]="Secret key:"
R[70]="Секретный ключ:"
E[71]="Current operating system is \$SYS.\\\n The system lower than \$SYSTEM \${MAJOR[int]} is not supported. Feedback: [https://github.com/cortez24rus/xui-reverse-proxy/issues]"
R[71]="Текущая операционная система: \$SYS.\\\n Система с версией ниже, чем \$SYSTEM \${MAJOR[int]}, не поддерживается. Обратная связь: [https://github.com/cortez24rus/xui-reverse-proxy/issues]"
E[72]="Install dependence-list:"
R[72]="Список зависимостей для установки:"
E[73]="All dependencies already exist and do not need to be installed additionally."
R[73]="Все зависимости уже установлены и не требуют дополнительной установки."
E[74]="OS - $SYS"
R[74]="OS - $SYS"
E[75]="Invalid option for --$key: $value. Use 'true' or 'false'."
R[75]="Неверная опция для --$key: $value. Используйте 'true' или 'false'."
E[76]="Unknown option: $1"
R[76]="Неверная опция: $1"
E[77]="List of dependencies for installation:"
R[77]="Список зависимостей для установки:"
E[78]="All dependencies are already installed and do not require additional installation."
R[78]="Все зависимости уже установлены и не требуют дополнительной установки."
E[79]="Configuring site template."
R[79]="Настройка шаблона сайта."
E[80]="Random template name:"
R[80]="Случайное имя шаблона:"
E[81]="Enter the second domain name:"
R[81]="Введите второе доменное имя:"
E[82]="Enter Shell in a box path:"
R[82]="Введите путь к Shell in a box:"
E[83]="Terminal emulator Shell in a box."
R[83]="Эмулятор терминала Shell in a box."
E[84]="0. Exit script"
R[84]="0. Выход из скрипта"
E[85]="MENU $VERSION_MANAGER"
R[85]="МЕНЮ $VERSION_MANAGER"
E[86]="1. Standard installation"
R[86]="1. Стандартная установка"
E[87]="2. Copy someone else's website to your server, experimental option"
R[87]="2. Скопировать чужой сайт на ваш сервер, экспериментальная опция"
E[88]="3. Change the domain name for the proxy"
R[88]="3. Изменить доменное имя для прокси"
E[89]="4. Forced reissue of certificates"
R[89]="4. Принудительный перевыпуск сертификатов"
E[90]="5. Disable IPv6"
R[90]="5. Отключение IPv6"
E[91]="6. Enable IPv6"
R[91]="6. Включение IPv6"
E[92]=""
R[92]=""


###################################
### Help output
###################################
show_help() {
  echo
  echo "Usage: reverse_proxy_server.sh [-u|--utils <true|false>] [-d|--dns <true|false>] [-a|--addu <true|false>]"
  echo "       [-r|--autoupd <true|false>] [-b|--bbr <true|false>] [-i|--ipv6 <true|false>] [-w|--warp <true|false>]"
  echo "       [-c|--cert <true|false>] [-m|--mon <true|false>] [-l|--shell <true|false>] [-n|--nginx <true|false>]"
  echo "       [-p|--panel <true|false>] [-f|--firewall <true|false>] [-s|--ssh <true|false>] [-t|--tgbot <true|false>]"
  echo "       [-g|--generate <true|false>] [-x|--skip-check <true|false>] [-o|--subdomain <true|false>] [-h|--help]"
  echo
  echo "  -u, --utils <true|false>       Additional utilities                             (default: ${defaults[utils]})"
  echo "                                 Дополнительные утилиты"
  echo "  -d, --dns <true|false>         DNS encryption                                   (default: ${defaults[dns]})"
  echo "                                 Шифрование DNS"
  echo "  -a, --addu <true|false>        User addition                                    (default: ${defaults[addu]})"
  echo "                                 Добавление пользователя"
  echo "  -r, --autoupd <true|false>     Automatic updates                                (default: ${defaults[autoupd]})"
  echo "                                 Автоматические обновления"
  echo "  -b, --bbr <true|false>         BBR (TCP Congestion Control)                     (default: ${defaults[bbr]})"
  echo "                                 BBR (управление перегрузкой TCP)"
  echo "  -i, --ipv6 <true|false>        Disable IPv6 support                             (default: ${defaults[ipv6]})"
  echo "                                 Отключить поддержку IPv6 "
  echo "  -w, --warp <true|false>        WARP setting                                     (default: ${defaults[warp]})"
  echo "                                 Настройка WARP"
  echo "  -c, --cert <true|false>        Certificate issuance for domain                  (default: ${defaults[cert]})"
  echo "                                 Выпуск сертификатов для домена"
  echo "  -m, --mon <true|false>         Monitoring services (node_exporter)              (default: ${defaults[mon]})"
  echo "                                 Сервисы мониторинга (node_exporter)"
  echo "  -l, --shell <true|false>       Shell In A Box installation                      (default: ${defaults[shell]})"
  echo "                                 Установка Shell In A Box"
  echo "  -n, --nginx <true|false>       NGINX installation                               (default: ${defaults[nginx]})"
  echo "                                 Установка NGINX"
  echo "  -p, --panel <true|false>       Panel installation for user management           (default: ${defaults[panel]})"
  echo "                                 Установка панели для управления пользователями"
  echo "  -f, --firewall <true|false>    Firewall configuration                           (default: ${defaults[firewall]})"
  echo "                                 Настройка файрвола"
  echo "  -s, --ssh <true|false>         SSH access                                       (default: ${defaults[ssh]})"
  echo "                                 SSH доступ"
  echo "  -t, --tgbot <true|false>       Telegram bot integration                         (default: ${defaults[tgbot]})"
  echo "                                 Интеграция Telegram бота"
  echo "  -g, --generate <true|false>    Generate a random string for configuration       (default: ${defaults[generate]})"
  echo "                                 Генерация случайных путей для конфигурации"
  echo "  -x, --skip-check <true|false>  Disable the check functionality                  (default: ${defaults[skip-check]})"
  echo "                                 Отключение проверки"
  echo "  -o, --subdomain <true|false>   Support for subdomains                           (default: ${defaults[subdomain]})"
  echo "                                 Поддержка субдоменов"
  echo "  -h, --help                     Display this help message"
  echo "                                 Показать это сообщение помощи"
  echo
  exit 0
}

###################################
### Reverse_proxy manager
###################################
update_reverse_proxy() {
  # Путь к файлу обновления
  UPDATE_SCRIPT="/usr/local/reverse_proxy/reverse_proxy"

  # Скрипт обновления
  wget -O $UPDATE_SCRIPT $SCRIPT_URL
  ln -sf $UPDATE_SCRIPT /usr/local/bin/reverse_proxy
  chmod +x $UPDATE_SCRIPT

  # Сделать файл исполнимым
  chmod +x "$UPDATE_SCRIPT"
  # Добавление задачи в crontab для выполнения каждый день в полночь
  CRON_RULE2="0 0 * * * reverse_proxy --update"
  ( crontab -l | grep -Fxq "$CRON_RULE2" ) || ( crontab -l; echo "$CRON_RULE2" ) | crontab -
}

###################################
### Reading values ​​from file
################################### 
read_defaults_from_file() {
  if [[ -f $DEFAULT_FILE ]]; then
    # Чтение и выполнение строк из файла
    while IFS= read -r line; do
      # Пропускаем пустые строки и комментарии
      [[ -z "$line" || "$line" =~ ^# ]] && continue
      eval "$line"
    done < $DEFAULT_FILE
  else
    # Если файл не найден, используем значения по умолчанию
    defaults[utils]=true
    defaults[dns]=true
    defaults[addu]=true
    defaults[autoupd]=true
    defaults[bbr]=true
    defaults[ipv6]=true
    defaults[warp]=true
    defaults[cert]=true
    defaults[mon]=false
    defaults[shell]=false
    defaults[nginx]=true
    defaults[panel]=true
    defaults[firewall]=true
    defaults[ssh]=true
    defaults[tgbot]=false
    defaults[generate]=true
    defaults[skip-check]=false
    defaults[subdomain]=false
  fi
}

###################################
### Writing values ​​to a file
###################################
write_defaults_to_file() {
  cat > ${DEFAULT_FILE}<<EOF
defaults[utils]=false
defaults[dns]=false
defaults[addu]=false
defaults[autoupd]=false
defaults[bbr]=false
defaults[ipv6]=false
defaults[warp]=false
defaults[cert]=false
defaults[mon]=false
defaults[shell]=false
defaults[nginx]=true
defaults[panel]=true
defaults[firewall]=false
defaults[ssh]=false
defaults[tgbot]=false
defaults[generate]=true
defaults[skip-check]=false
defaults[subdomain]=false
EOF
}

###################################
### Lowercase characters
################################### 
normalize_case() {
  local key=$1
  args[$key]="${args[$key],,}"
}

###################################
### Validation of true/false value
################################### 
validate_true_false() {
  local key=$1
  local value=$2
  case ${value} in
    true)
      args[$key]=true
      ;;
    false)
      args[$key]=false
      ;;
    *)
      warning " $(text 75) "
      return 1
      ;;
  esac
}

###################################
### Parse args
###################################
parse_args() {
  local opts
  opts=$(getopt -o hu:d:a:r:b:i:w:c:m:l:n:p:f:s:t:g:x:o --long utils:,dns:,addu:,autoupd:,bbr:,ipv6:,warp:,cert:,mon:,shell:,nginx:,panel:,firewall:,ssh:,tgbot:,generate:,skip-check:,subdomain:,update,help -- "$@")
  if [[ $? -ne 0 ]]; then
    return 1
  fi
  eval set -- "$opts"
  while true; do
    case $1 in
      -u|--utils)
        args[utils]="$2"
        normalize_case utils
        validate_true_false utils "$2" || return 1
        shift 2
        ;;
      -d|--dns)
        args[dns]="$2"
        normalize_case dns
        validate_true_false dns "$2" || return 1
        shift 2
        ;;
      -a|--addu)
        args[addu]="$2"
        normalize_case addu
        validate_true_false addu "$2" || return 1
        shift 2
        ;;
      -r|--autoupd)
        args[autoupd]="$2"
        normalize_case autoupd
        validate_true_false autoupd "$2" || return 1
        shift 2
        ;;
      -b|--bbr)
        args[bbr]="$2"
        normalize_case bbr
        validate_true_false bbr "$2" || return 1
        shift 2
        ;;
      -i|--ipv6)
        args[ipv6]="$2"
        normalize_case ipv6
        validate_true_false ipv6 "$2" || return 1
        shift 2
        ;;
      -w|--warp)
        args[warp]="$2"
        normalize_case warp
        validate_true_false warp "$2" || return 1
        shift 2
        ;;
      -c|--cert)
        args[cert]="$2"
        normalize_case cert
        validate_true_false cert "$2" || return 1
        shift 2
        ;;
      -m|--mon)
        args[mon]="$2"
        normalize_case mon
        validate_true_false mon "$2" || return 1
        shift 2
        ;;
      -l|--shell)
        args[shell]="$2"
        normalize_case shell
        validate_true_false shell "$2" || return 1
        shift 2
        ;;
      -n|--nginx)
        args[nginx]="$2"
        normalize_case nginx
        validate_true_false nginx "$2" || return 1
        shift 2
        ;;
      -p|--panel)
        args[panel]="$2"
        normalize_case panel
        validate_true_false panel "$2" || return 1
        shift 2
        ;;
      -f|--firewall)
        args[firewall]="$2"
        normalize_case firewall
        validate_true_false firewall "$2" || return 1
        shift 2
        ;;
      -s|--ssh)
        args[ssh]="$2"
        normalize_case ssh
        validate_true_false ssh "$2" || return 1
        shift 2
        ;;
      -t|--tgbot)
        args[tgbot]="$2"
        normalize_case tgbot
        validate_true_false tgbot "$2" || return 1
        shift 2
        ;;
      -g|--generate)
        args[generate]="$2"
        normalize_case generate
        validate_true_false generate "$2" || return 1
        shift 2
        ;;
      -x|--skip-check)
        args[skip-check]="$2"
        normalize_case skip-check
        validate_true_false skip-check "$2" || return 1
        shift 2
        ;;
      -o|--subdomain)
        args[subdomain]="$2"
        normalize_case subdomain
        validate_true_false subdomain "$2" || return 1
        shift 2
        ;;
      --update)
        CURRENT_VERSION=$(wget -qO- $SCRIPT_URL | grep -E "^\s*VERSION_MANAGER=" | cut -d'=' -f2)
        warning "Script update version: $CURRENT_VERSION"
        echo
        update_reverse_proxy
        exit 0
        ;;
      -h|--help)
        return 1
        ;;
      --)
        shift
        break
        ;;
      *)
        warning " $(text 76) "
        return 1
        ;;
    esac
  done

  for key in "${!defaults[@]}"; do
    if [[ -z "${args[$key]}" ]]; then
      args[$key]=${defaults[$key]}
    fi
  done
}

###################################
### Logging
###################################
log_entry() {
  mkdir -p /usr/local/reverse_proxy/
  LOGFILE="/usr/local/reverse_proxy/reverse_proxy.log"
  exec > >(tee -a "$LOGFILE") 2>&1
}

###################################
### Language selection
###################################
select_language() {
  L=E
  hint " $(text 0) \n"  # Показывает информацию о доступных языках
  reading " $(text 1) " LANGUAGE  # Запрашивает выбор языка

  # Устанавливаем язык в зависимости от выбора
  case "$LANGUAGE" in
  1) L=E ;;   # Если выбран английский
  2) L=R ;;   # Если выбран русский
#  3) L=C ;;   # Если выбран китайский
#  4) L=F ;;   # Если выбран персидский
  *) L=E ;;   # По умолчанию — английский
  esac
}

###################################
### Checking the operating system
###################################
check_operating_system() {
  if [ -s /etc/os-release ]; then
    SYS="$(grep -i pretty_name /etc/os-release | cut -d \" -f2)"
  elif [ -x "$(type -p hostnamectl)" ]; then
    SYS="$(hostnamectl | grep -i system | cut -d : -f2)"
  elif [ -x "$(type -p lsb_release)" ]; then
    SYS="$(lsb_release -sd)"
  elif [ -s /etc/lsb-release ]; then
    SYS="$(grep -i description /etc/lsb-release | cut -d \" -f2)"
  elif [ -s /etc/redhat-release ]; then
    SYS="$(grep . /etc/redhat-release)"
  elif [ -s /etc/issue ]; then
    SYS="$(grep . /etc/issue | cut -d '\' -f1 | sed '/^[ ]*$/d')"
  fi

  REGEX=("debian" "ubuntu" "centos|red hat|kernel|alma|rocky")
  RELEASE=("Debian" "Ubuntu" "CentOS")
  EXCLUDE=("---")
  MAJOR=("10" "20" "7")
  PACKAGE_UPDATE=("apt -y update" "apt -y update" "yum -y update --skip-broken")
  PACKAGE_INSTALL=("apt -y install" "apt -y install" "yum -y install")
  PACKAGE_UNINSTALL=("apt -y autoremove" "apt -y autoremove" "yum -y autoremove")

  for int in "${!REGEX[@]}"; do
    [[ "${SYS,,}" =~ ${REGEX[int]} ]] && SYSTEM="${RELEASE[int]}" && break
  done

  # Проверка на кастомизированные системы от различных производителей
  if [ -z "$SYSTEM" ]; then
    [ -x "$(type -p yum)" ] && int=2 && SYSTEM='CentOS' || error " $(text 5) "
  fi

  # Определение основной версии Linux
  MAJOR_VERSION=$(sed "s/[^0-9.]//g" <<< "$SYS" | cut -d. -f1)

  # Сначала исключаем системы, указанные в EXCLUDE, затем для оставшихся делаем сравнение по основной версии
  for ex in "${EXCLUDE[@]}"; do [[ ! "${SYS,,}" =~ $ex ]]; done &&
  [[ "$MAJOR_VERSION" -lt "${MAJOR[int]}" ]] && error " $(text 71) "
}

###################################
### Checking and installing dependencies
###################################
check_dependencies() {
  # Зависимости, необходимые для трех основных систем
  [ "${SYSTEM}" = 'CentOS' ] && ${PACKAGE_INSTALL[int]} vim-common epel-release
  DEPS_CHECK=("ping" "wget" "curl" "systemctl" "ip" "sudo")
  DEPS_INSTALL=("iputils-ping" "wget" "curl" "systemctl" "iproute2" "sudo")

  for g in "${!DEPS_CHECK[@]}"; do
    [ ! -x "$(type -p ${DEPS_CHECK[g]})" ] && [[ ! "${DEPS[@]}" =~ "${DEPS_INSTALL[g]}" ]] && DEPS+=(${DEPS_INSTALL[g]})
  done

  if [ "${#DEPS[@]}" -ge 1 ]; then
    info "\n $(text 72) ${DEPS[@]} \n"
    ${PACKAGE_UPDATE[int]}
    ${PACKAGE_INSTALL[int]} ${DEPS[@]}
  else
    info "\n $(text 73) \n"
  fi
}

###################################
### Root check
###################################
check_root() {
  if [[ $EUID -ne 0 ]]; then
    error " $(text 8) "
  fi
}

###################################
### Banner
###################################
banner_xray() {
  echo
  echo " █░█ █░░█ ░▀░ ░░ █▀▀█ █▀▀ ▀█░█▀ █▀▀ █▀▀█ █▀▀ █▀▀ ░░ █▀▀█ █▀▀█ █▀▀█ █░█ █░░█  "
  echo " ▄▀▄ █░░█ ▀█▀ ▀▀ █▄▄▀ █▀▀ ░█▄█░ █▀▀ █▄▄▀ ▀▀█ █▀▀ ▀▀ █░░█ █▄▄▀ █░░█ ▄▀▄ █▄▄█  "
  echo " ▀░▀ ░▀▀▀ ▀▀▀ ░░ ▀░▀▀ ▀▀▀ ░░▀░░ ▀▀▀ ▀░▀▀ ▀▀▀ ▀▀▀ ░░ █▀▀▀ ▀░▀▀ ▀▀▀▀ ▀░▀ ▄▄▄█  "
  echo
  echo
}

###################################
### Installation request
###################################
warning_banner() {
  warning " $(text 5) "
  echo
  info " $(text 6) "
  warning " apt-get update && apt-get full-upgrade -y && reboot "
}

###################################
### Obtaining your external IP address
###################################
check_ip() {
    IP4_REGEX="^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$"
    IP4=$(ip route get 8.8.8.8 2>/dev/null | grep -Po -- 'src \K\S*')

    if [[ ! $IP4 =~ $IP4_REGEX ]]; then
        IP4=$(curl -s --max-time 5 ipinfo.io/ip 2>/dev/null)
    fi

    if [[ ! $IP4 =~ $IP4_REGEX ]]; then
      echo "Не удалось получить внешний IP."
      return 1
    fi
}

###################################
### Request and response from Cloudflare API
###################################
get_test_response() {
  testdomain=$(echo "${DOMAIN}" | rev | cut -d '.' -f 1-2 | rev)

  if [[ "$CFTOKEN" =~ [A-Z] ]]; then
    test_response=$(curl --silent --request GET --url https://api.cloudflare.com/client/v4/zones --header "Authorization: Bearer ${CFTOKEN}" --header "Content-Type: application/json")
  else
    test_response=$(curl --silent --request GET --url https://api.cloudflare.com/client/v4/zones --header "X-Auth-Key: ${CFTOKEN}" --header "X-Auth-Email: ${EMAIL}" --header "Content-Type: application/json")
  fi
}

###################################
### Function to clean the URL (removes the protocol, port, and path)
###################################
clean_url() {
    local INPUT_URL_L="$1"  # Входной URL, который нужно очистить от префикса, порта и пути.
    # Убираем префикс https:// или http:// и порт/путь
    local CLEANED_URL_L=$(echo "$INPUT_URL_L" | sed -E 's/^https?:\/\///' | sed -E 's/(:[0-9]+)?(\/[a-zA-Z0-9_\-\/]+)?$//')
    echo "$CLEANED_URL_L"  # Возвращаем очищенный URL (без префикса, порта и пути).
}

###################################
### Function to crop the domain to the last two parts
###################################
crop_domain() {
    local DOMAIN_L=$1  # Получаем домен как аргумент
    IFS='.' read -r -a parts <<< "$DOMAIN_L"  # Разбиваем домен на части по точкам.

    # Если в домене больше двух частей (например, для субдоменов), обрезаем до последних двух.
    if [ ${#parts[@]} -gt 2 ]; then
      DOMAIN_L="${parts[${#parts[@]}-2]}.${parts[${#parts[@]}-1]}"  # Берем последние две части домена.
    else
      DOMAIN_L="${parts[0]}.${parts[1]}"  # Если домен второго уровня, оставляем только его.
    fi

    echo "$DOMAIN_L"  # Возвращаем результат через echo.
}

###################################
### Domain validation in cloudflare
###################################
check_cf_token() {
  # Пока не получим правильный ответ, продолжаем выполнение.
  while ! echo "$test_response" | grep -qE "\"${testdomain}\"|\"#dns_records:edit\"|\"#dns_records:read\"|\"#zone:read\""; do
    local TEMP_DOMAIN_L_L  # Переменная для временного домена
    DOMAIN=""  # Обнуляем переменную домена
    SUB_DOMAIN=""  # Обнуляем переменную субдомена

    # Если флаг subdomain равен true, запрашиваем субдомен и домен.
    if [[ ${args[subdomain]} == "true" ]]; then
      reading " $(text 13) " TEMP_DOMAIN_L  # Запрашиваем домен
      DOMAIN=$(clean_url "$TEMP_DOMAIN_L")  # Очищаем домен
      echo
      reading " $(text 81) " TEMP_DOMAIN_L  # Запрашиваем субдомен
      SUB_DOMAIN=$(clean_url "$TEMP_DOMAIN_L")  # Очищаем субдомен
    else
      # Если subdomain не задан, продолжаем работать с доменом.
      while [[ -z "$TEMP_DOMAIN_L" ]]; do
        reading " $(text 13) " TEMP_DOMAIN_L  # Запрашиваем домен
        TEMP_DOMAIN_L=$(clean_url "$TEMP_DOMAIN_L")  # Очищаем домен
        echo
      done

      # Проверяем, если домен соответствует регулярному выражению
      if [[ "$TEMP_DOMAIN_L" =~ ${regex[domain]} ]]; then
        DOMAIN=$(crop_domain "$TEMP_DOMAIN_L")  # Обрезаем домен до последних двух частей
        SUB_DOMAIN="$TEMP_DOMAIN_L"  # Весь домен сохраняем в SUB_DOMAIN
      else
        DOMAIN="$TEMP_DOMAIN_L"  # Если домен второго уровня, сохраняем его без изменений
        SUB_DOMAIN="www.$TEMP_DOMAIN_L"  # Для домена второго уровня добавляем www в SUB_DOMAIN
      fi
    fi

    # Запрашиваем email пользователя
    while [[ -z $EMAIL ]]; do
      reading " $(text 15) " EMAIL
      echo
    done

    # Запрашиваем Cloudflare токен
    while [[ -z $CFTOKEN ]]; do
      reading " $(text 16) " CFTOKEN
    done

    # Если флаг skip-check не задан как true, выполняем запрос на тестовый ответ
    [[ ${args[skip-check]} == "false" ]] && get_test_response
    info " $(text 17) "
  done
}

###################################
### Processing paths with a loop
###################################
validate_path() {
  local VARIABLE_NAME="$1"
  local PATH_VALUE

  # Проверка на пустое значение
  while true; do
    case "$VARIABLE_NAME" in
      CDNGRPC)
        reading " $(text 20) " PATH_VALUE
        ;;
      CDNSPLIT)
        reading " $(text 21) " PATH_VALUE
        ;;
      CDNHTTPU)
        reading " $(text 22) " PATH_VALUE
        ;;
      CDNWS)
        reading " $(text 23) " PATH_VALUE
        ;;
      METRICS)
        reading " $(text 24) " PATH_VALUE
        ;;
      SHELLBOX)
        reading " $(text 24) " PATH_VALUE
        ;;
      ADGUARDPATH)
        reading " $(text 25) " PATH_VALUE
        ;;
      WEB_BASE_PATH)
        reading " $(text 26) " PATH_VALUE
        ;;
      SUB_PATH)
        reading " $(text 27) " PATH_VALUE
        ;;
      SUB_JSON_PATH)
        reading " $(text 28) " PATH_VALUE
        ;;
    esac

    if [[ -z "$PATH_VALUE" ]]; then
      warning " $(text 29) "
      echo
    elif [[ $PATH_VALUE =~ ['{}\$/\\'] ]]; then
      warning " $(text 30) "
      echo
    else
      break
    fi
  done
  
  # Экранируем пробелы в пути
  local ESCAPED_PATH=$(echo "$PATH_VALUE" | sed 's/ /\\ /g')

  # Присваиваем значение переменной
  case "$VARIABLE_NAME" in
    CDNGRPC)
      export CDNGRPC="$ESCAPED_PATH"
      ;;
    CDNSPLIT)
      export CDNSPLIT="$ESCAPED_PATH"
      ;;
    CDNHTTPU)
      export CDNHTTPU="$ESCAPED_PATH"
      ;;
    CDNWS)
      export CDNWS="$ESCAPED_PATH"
      ;;
    METRICS)
      export METRICS="$ESCAPED_PATH"
      ;;
    SHELLBOX)
      export SHELLBOX="$ESCAPED_PATH"
      ;;
    ADGUARDPATH)
      export ADGUARDPATH="$ESCAPED_PATH"
      ;;
    WEB_BASE_PATH)
      export WEB_BASE_PATH="$ESCAPED_PATH"
      ;;
    SUB_PATH)
      export SUB_PATH="$ESCAPED_PATH"
      ;;
    SUB_JSON_PATH)
      export SUB_JSON_PATH="$ESCAPED_PATH"
      ;;
  esac
}

###################################
### DNS Selection
###################################
choise_dns () {
  while true; do
    hint " $(text 31) \n" && reading " $(text 1) " CHOISE_DNS
    case $CHOISE_DNS in
      1)
        info " $(text 32) "
        break
        ;;
      2)
        info " $(text 25) "
        if [[ ${args[generate]} == "true" ]]; then
          ADGUARDPATH=$(eval ${generate[path]})
        else
          echo
          tilda "$(text 10)"
          validate_path ADGUARDPATH
        fi
        echo
        break
        ;;
      *)
        info " $(text 33) "
        ;;
    esac
  done
}

###################################
### Data entry
###################################
data_entry() {
  tilda "$(text 10)"
#  reading " $(text 70) " SECRET_PASSWORD

  reading " $(text 11) " USERNAME
  echo
  reading " $(text 12) " PASSWORD
  [[ ${args[addu]} == "true" ]] && add_user

  tilda "$(text 10)"

  check_cf_token

  tilda "$(text 10)"

  choise_dns

  tilda "$(text 10)"

  reading " $(text 19) " REALITY

  if [[ ${args[generate]} == "true" ]]; then
    echo
    CDNGRPC=$(eval ${generate[path]})
    CDNSPLIT=$(eval ${generate[path]})
    CDNHTTPU=$(eval ${generate[path]})
    CDNWS=$(eval ${generate[path]})
    WEB_BASE_PATH=$(eval ${generate[path]})
    SUB_PATH=$(eval ${generate[path]})
    SUB_JSON_PATH=$(eval ${generate[path]})
  else
    echo
    validate_path CDNGRPC
    echo
    validate_path CDNSPLIT
    echo
    validate_path CDNHTTPU
    echo
    validate_path CDNWS
    tilda "$(text 10)"
    validate_path WEB_BASE_PATH
    echo
    validate_path SUB_PATH
    echo
    validate_path SUB_JSON_PATH
  fi

  if [[ ${args[mon]} == "true" ]]; then
    if [[ ${args[generate]} == "true" ]]; then
      METRICS=$(eval ${generate[path]})
    else
      echo
      validate_path METRICS
    fi
  fi

  if [[ ${args[shell]} == "true" ]]; then
    if [[ ${args[generate]} == "true" ]]; then
      SHELLBOX=$(eval ${generate[path]})
    else
      echo
      validate_path SHELLBOX
    fi
  fi

  if [[ ${args[ssh]} == "true" ]]; then
    tilda "$(text 10)"
    reading " $(text 54) " ANSWER_SSH
    if [[ "${ANSWER_SSH,,}" == "y" ]]; then
      info " $(text 48) "
      out_data " $(text 49) "
      echo
      out_data " $(text 50) "
      out_data " $(text 51) "
      echo
      out_data " $(text 52)" "type \$env:USERPROFILE\.ssh\id_rsa.pub | ssh -p 22 ${USERNAME}@${IP4} \"cat >> ~/.ssh/authorized_keys\""
      out_data " $(text 53)" "ssh-copy-id -p 22 ${USERNAME}@${IP4}"
      echo

      # Цикл проверки наличия ключей
      while true; do
        if [[ -s "/home/${USERNAME}/.ssh/authorized_keys" || -s "/root/.ssh/authorized_keys" ]]; then
          info " $(text 56) " # Ключи найдены
          SSH_OK=true
          break
        else
          warning " $(text 55) " # Ключи отсутствуют
          echo
          reading " $(text 54) " ANSWER_SSH
          if [[ "${ANSWER_SSH,,}" != "y" ]]; then
            warning " $(text 9) " # Настройка отменена
            SSH_OK=false
            break
          fi
        fi
      done
      tilda "$(text 10)"
    else
      warning " $(text 9) " # Настройка пропущена
      SSH_OK=false
    fi
  fi

  if [[ ${args[tgbot]} == "true" ]]; then
    reading " $(text 35) " ADMIN_ID
    echo
    reading " $(text 34) " BOT_TOKEN
  fi

  SUB_URI=https://${DOMAIN}/${SUB_PATH}/
  SUB_JSON_URI=https://${DOMAIN}/${SUB_JSON_PATH}/
  tilda "$(text 10)"
}

###################################
### Install NGINX
###################################
nginx_gpg() {
  case "$SYSTEM" in
    Debian)
      ${PACKAGE_INSTALL[int]} debian-archive-keyring
      curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor \
        | tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null
      gpg --dry-run --quiet --no-keyring --import --import-options import-show /usr/share/keyrings/nginx-archive-keyring.gpg
      echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] \
      http://nginx.org/packages/debian `lsb_release -cs` nginx" \
        | tee /etc/apt/sources.list.d/nginx.list
      echo -e "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" \
        | tee /etc/apt/preferences.d/99nginx
      ;;

    Ubuntu)
      ${PACKAGE_INSTALL[int]} ubuntu-keyring
      curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor \
        | tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null
      gpg --dry-run --quiet --no-keyring --import --import-options import-show /usr/share/keyrings/nginx-archive-keyring.gpg
      echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] \
      http://nginx.org/packages/ubuntu `lsb_release -cs` nginx" \
        | tee /etc/apt/sources.list.d/nginx.list
      echo -e "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" \
        | tee /etc/apt/preferences.d/99nginx
      ;;

    CentOS|Fedora)
      ${PACKAGE_INSTALL[int]} yum-utils
      cat <<EOL > /etc/yum.repos.d/nginx.repo
[nginx-stable]
name=nginx stable repo
baseurl=http://nginx.org/packages/centos/\$releasever/\$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true

[nginx-mainline]
name=nginx mainline repo
baseurl=http://nginx.org/packages/mainline/centos/\$releasever/\$basearch/
gpgcheck=1
enabled=0
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true
EOL
      ;;
  esac
  ${PACKAGE_UPDATE[int]}
  ${PACKAGE_INSTALL[int]} nginx
  systemctl daemon-reload
  systemctl start nginx
  systemctl enable nginx
  systemctl restart nginx
  systemctl status nginx --no-pager
}

###################################
### Installing packages
###################################
installation_of_utilities() {
  info " $(text 36) "
  case "$SYSTEM" in
    Debian|Ubuntu)
      DEPS_PACK_CHECK=("jq" "ufw" "zip" "wget" "gpg" "nano" "cron" "sqlite3" "certbot" "openssl" "netstat" "htpasswd" "update-ca-certificates" "add-apt-repository" "unattended-upgrades" "certbot-dns-cloudflare")
      DEPS_PACK_INSTALL=("jq" "ufw" "zip" "wget" "gnupg2" "nano" "cron" "sqlite3" "certbot" "openssl" "net-tools" "apache2-utils" "ca-certificates" "software-properties-common" "unattended-upgrades" "python3-certbot-dns-cloudflare")

      for g in "${!DEPS_PACK_CHECK[@]}"; do
        [ ! -x "$(type -p ${DEPS_PACK_CHECK[g]})" ] && [[ ! "${DEPS_PACK[@]}" =~ "${DEPS_PACK_INSTALL[g]}" ]] && DEPS_PACK+=(${DEPS_PACK_INSTALL[g]})
      done

      if [ "${#DEPS_PACK[@]}" -ge 1 ]; then
        info " $(text 77) ": ${DEPS_PACK[@]}
        ${PACKAGE_UPDATE[int]}
        ${PACKAGE_INSTALL[int]} ${DEPS_PACK[@]}
      else
        info " $(text 78) "
      fi
      ;;

    CentOS|Fedora)
      DEPS_PACK_CHECK=("jq" "zip" "tar" "wget" "gpg" "nano" "crontab" "sqlite3" "openssl" "netstat" "nslookup" "htpasswd" "certbot" "update-ca-certificates" "certbot-dns-cloudflare")
      DEPS_PACK_INSTALL=("jq" "zip" "tar" "wget" "gnupg2" "nano" "cronie" "sqlite" "openssl" "net-tools" "bind-utils" "httpd-tools" "certbot" "ca-certificates" "python3-certbot-dns-cloudflare")

      for g in "${!DEPS_PACK_CHECK[@]}"; do
        [ ! -x "$(type -p ${DEPS_PACK_CHECK[g]})" ] && [[ ! "${DEPS_PACK[@]}" =~ "${DEPS_PACK_INSTALL[g]}" ]] && DEPS_PACK+=(${DEPS_PACK_INSTALL[g]})
      done

      if [ "${#DEPS_PACK[@]}" -ge 1 ]; then
        info " $(text 77) ": ${DEPS_PACK[@]}
        ${PACKAGE_UPDATE[int]}
        ${PACKAGE_INSTALL[int]} ${DEPS_PACK[@]}
      else
        info " $(text 78) "
      fi
      ;;
  esac

  nginx_gpg
  ${PACKAGE_INSTALL[int]} systemd-resolved
  tilda "$(text 10)"
}

###################################
### DNS Systemd-resolved
###################################
dns_systemd_resolved() {
  tee /etc/systemd/resolved.conf <<EOF
[Resolve]
DNS=1.1.1.1 8.8.8.8 8.8.4.4
#FallbackDNS=
Domains=~.
DNSSEC=yes
DNSOverTLS=yes
EOF
  systemctl restart systemd-resolved.service
}

###################################
### DNS Adguardhome
###################################
dns_adguard_home() {
  rm -rf AdGuardHome_*
  while ! wget -q --progress=dot:mega --timeout=30 --tries=10 --retry-connrefused https://static.adguard.com/adguardhome/release/AdGuardHome_linux_amd64.tar.gz; do
    warning " $(text 38) "
    sleep 3
  done
  tar -zxvf AdGuardHome_linux_amd64.tar.gz

  AdGuardHome/AdGuardHome -s install
  HASH=$(htpasswd -B -C 10 -n -b ${USERNAME} ${PASSWORD} | cut -d ":" -f 2)

  rm -f AdGuardHome/AdGuardHome.yaml
  while ! wget -q --progress=dot:mega --timeout=30 --tries=10 --retry-connrefused "https://github.com/cortez24rus/xui-reverse-proxy/raw/refs/heads/main/adh/AdGuardHome.yaml" -O AdGuardHome/AdGuardHome.yaml; do
    warning " $(text 38) "
    sleep 3
  done

  sleep 1
  sed -i \
    -e "s|username|${USERNAME}|g" \
    -e "s|hash|${HASH}|g" \
    AdGuardHome/AdGuardHome.yaml

  AdGuardHome/AdGuardHome -s restart
}

###################################
### Dns systemd for adguard
###################################
dns_systemd_resolved_for_adguard() {
  tee /etc/systemd/resolved.conf <<EOF
[Resolve]
DNS=127.0.0.1
#FallbackDNS=
#Domains=
#DNSSEC=no
DNSOverTLS=no
DNSStubListener=no
EOF
  systemctl restart systemd-resolved.service
}

###################################
### DNS menu
###################################
dns_encryption() {
  info " $(text 37) "
  dns_systemd_resolved
  case $CHOISE_DNS in
    1)
      COMMENT_AGH=""
      tilda "$(text 10)"
      ;;
    2)
      COMMENT_AGH="location /${ADGUARDPATH}/ {
    if (\$hack = 1) {return 404;}
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header Range \$http_range;
    proxy_set_header If-Range \$http_if_range;
    proxy_redirect /login.html /${ADGUARDPATH}/login.html;
    proxy_pass http://127.0.0.1:8081/;
    break;
  }"
      dns_adguard_home
      dns_systemd_resolved_for_adguard
      tilda "$(text 10)"
      ;;
    *)

      warning " $(text 33)"
      dns_encryption
      ;;
  esac
}

###################################
### Creating a user
###################################
add_user() {
  info " $(text 39) "

  case "$SYSTEM" in
    Debian|Ubuntu)
      useradd -m -s $(which bash) -G sudo ${USERNAME}
      ;;

    CentOS|Fedora)
      useradd -m -s $(which bash) -G wheel ${USERNAME}
      ;;
  esac
  echo "${USERNAME}:${PASSWORD}" | chpasswd
  mkdir -p /home/${USERNAME}/.ssh/
  touch /home/${USERNAME}/.ssh/authorized_keys
  chown -R ${USERNAME}: /home/${USERNAME}/.ssh
  chmod -R 700 /home/${USERNAME}/.ssh

  tilda "$(text 10)"
}

###################################
### Automatic system update
###################################
setup_auto_updates() {
  info " $(text 40) "

  case "$SYSTEM" in
    Debian|Ubuntu)
      echo 'Unattended-Upgrade::Mail "root";' >> /etc/apt/apt.conf.d/50unattended-upgrades
      echo unattended-upgrades unattended-upgrades/enable_auto_updates boolean true | debconf-set-selections
      dpkg-reconfigure -f noninteractive unattended-upgrades
      systemctl restart unattended-upgrades
      ;;

    CentOS|Fedora)
      cat > /etc/dnf/automatic.conf <<EOF
[commands]
upgrade_type = security
random_sleep = 0
download_updates = yes
apply_updates = yes

[email]
email_from = root@localhost
email_to = root
email_host = localhost
EOF
      systemctl enable --now dnf-automatic.timer
      systemctl status dnf-automatic.timer
      ;;
  esac

  tilda "$(text 10)"
}

###################################
### BBR
###################################
enable_bbr() {
  info " $(text 41) "

  if ! grep -q "net.core.default_qdisc = fq" /etc/sysctl.conf; then
      echo "net.core.default_qdisc = fq" >> /etc/sysctl.conf
  fi
  if ! grep -q "net.ipv4.tcp_congestion_control = bbr" /etc/sysctl.conf; then
      echo "net.ipv4.tcp_congestion_control = bbr" >> /etc/sysctl.conf
  fi

  sysctl -p
}

###################################
### Disable IPv6
###################################
disable_ipv6() {
  info " $(text 42) "
  interface_name=$(ifconfig -s | awk 'NR==2 {print $1}')

  if ! grep -q "net.ipv6.conf.all.disable_ipv6 = 1" /etc/sysctl.conf; then
      echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
  fi
  if ! grep -q "net.ipv6.conf.default.disable_ipv6 = 1" /etc/sysctl.conf; then
      echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
  fi
  if ! grep -q "net.ipv6.conf.lo.disable_ipv6 = 1" /etc/sysctl.conf; then
      echo "net.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf
  fi
  if ! grep -q "net.ipv6.conf.$interface_name.disable_ipv6 = 1" /etc/sysctl.conf; then
      echo "net.ipv6.conf.$interface_name.disable_ipv6 = 1" >> /etc/sysctl.conf
  fi

  sysctl -p
  tilda "$(text 10)"
}

###################################
### Enable IPv6
###################################
enable_ipv6() {
  info " $(text 42) "
  interface_name=$(ifconfig -s | awk 'NR==2 {print $1}')

  sed -i "/net.ipv6.conf.all.disable_ipv6 = 1/d" /etc/sysctl.conf
  sed -i "/net.ipv6.conf.default.disable_ipv6 = 1/d" /etc/sysctl.conf
  sed -i "/net.ipv6.conf.lo.disable_ipv6 = 1/d" /etc/sysctl.conf
  sed -i "/net.ipv6.conf.$interface_name.disable_ipv6 = 1/d" /etc/sysctl.conf

  echo -e "IPv6 включен"
  sysctl -p
  tilda "$(text 10)"
}

###################################
### Swapfile
###################################
swapfile() {
  echo
  echo "Setting up swapfile and restarting the WARP service if necessary"
  swapoff /swapfile*
  dd if=/dev/zero of=/swapfile bs=1M count=512
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile
  swapon --show

  cat > /usr/local/reverse_proxy/restart_warp <<EOF
#!/bin/bash
# Получаем количество занятого пространства в swap (в мегабайтах)
SWAP_USED=$(free -m | grep Swap | awk '{print $3}')
# Проверяем, больше ли оно 300 Мб
if [ "$SWAP_USED" -gt 200 ]; then
    # Перезапускаем warp-svc.service
    systemctl restart warp-svc.service
    # Записываем дату и время в лог-файл
    echo "$(date '+%Y-%m-%d %H:%M:%S') - warp-svc.service перезапущен из-за превышения swap" >> /root/warp_restart_time
fi
EOF
  chmod +x /usr/local/reverse_proxy/restart_warp
  { crontab -l; echo "* * * * * /usr/local/reverse_proxy/restart_warp"; } | crontab -
}

###################################
### WARP
###################################
warp() {
  info " $(text 43) "

  curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(grep "VERSION_CODENAME=" /etc/os-release | cut -d "=" -f 2) main" | tee /etc/apt/sources.list.d/cloudflare-client.list  
  ${PACKAGE_UPDATE[int]}
  ${PACKAGE_INSTALL[int]} cloudflare-warp

#  mkdir -p /etc/systemd/system/warp-svc.service.d
#  cd /usr/local/reverse_proxy/

#  case "$SYSTEM" in
#    Debian|Ubuntu)
#      while ! wget --progress=dot:mega --timeout=30 --tries=10 --retry-connrefused "https://pkg.cloudflareclient.com/pool/$(grep "VERSION_CODENAME=" /etc/os-release | cut -d "=" -f 2)/main/c/cloudflare-warp/cloudflare-warp_2024.6.497-1_amd64.deb"; do
#        warning " $(text 38) "
#        sleep 3
#      done
#      apt install -y ./cloudflare-warp_2024.6.497-1_amd64.deb
#      ;;
#
#    CentOS|Fedora)
#      while ! wget --progress=dot:mega --timeout=30 --tries=10 --retry-connrefused "https://pkg.cloudflareclient.com/rpm/x86_64/cloudflare-warp-2024.6.497-1.x86_64.rpm"; do
#        warning " $(text 38) "
#        sleep 3
#      done
#      sudo yum localinstall -y cloudflare-warp-2024.6.497-1.x86_64.rpm
#      ;;
#  esac

#  rm -rf cloudflare-warp_*
#  cd ~

#  cat > /etc/systemd/system/warp-svc.service.d/override.conf <<EOF
#[Service]
#LogLevelMax=3
#EOF

#  systemctl daemon-reload
#  systemctl restart warp-svc.service
#  sleep 3

#  systemctl status warp-svc || echo "Служба warp-svc не найдена или не запустилась."

  sleep 1
  yes | warp-cli registration new
  sleep 1
  warp-cli mode proxy
  sleep 1
  warp-cli proxy port 40000
  sleep 1
  warp-cli connect
  sleep 1
  warp-cli debug qlog disable
  sleep 2

  warp-cli tunnel stats
  if curl -x socks5h://localhost:40000 https://2ip.io; then
    echo "Настройка завершена: WARP подключен и работает."
  else
    echo "Ошибка: не удалось подключиться к WARP через прокси. Проверьте настройки."
  fi

  swapfile
  tilda "$(text 10)"
}

###################################
### Certificates
###################################
issuance_of_certificates() {
  info " $(text 44) "
  CF_CREDENTIALS_PATH="/root/cloudflare.credentials"
  touch ${CF_CREDENTIALS_PATH}
  chown root:root ${CF_CREDENTIALS_PATH}
  chmod 600 ${CF_CREDENTIALS_PATH}

  if [[ "$CFTOKEN" =~ [A-Z] ]]; then
    cat > ${CF_CREDENTIALS_PATH} <<EOF
dns_cloudflare_api_token = ${CFTOKEN}
EOF
  else
    cat > ${CF_CREDENTIALS_PATH} <<EOF
dns_cloudflare_email = ${EMAIL}
dns_cloudflare_api_key = ${CFTOKEN}
EOF
  fi

  attempt=0
  max_attempts=2
  while [ $attempt -lt $max_attempts ]; do
    certbot certonly --dns-cloudflare --dns-cloudflare-credentials ${CF_CREDENTIALS_PATH} --dns-cloudflare-propagation-seconds 30 --rsa-key-size 4096 -d ${DOMAIN},*.${DOMAIN} --agree-tos -m ${EMAIL} --cert-name ${DOMAIN} --no-eff-email --non-interactive
	  if [ $? -eq 0 ]; then
      break
    else
      attempt=$((attempt + 1))
      sleep 5
    fi
  done

  CRON_RULE1="0 5 1 */2 * certbot -q renew"
  ( crontab -l | grep -Fxq "$CRON_RULE1" ) || ( crontab -l; echo "$CRON_RULE1" ) | crontab -
  tilda "$(text 10)"
}

###################################
### Node exporter
###################################
monitoring() {
  info " $(text 66) "
  bash <(curl -Ls https://github.com/cortez24rus/grafana-prometheus/raw/refs/heads/main/prometheus_node_exporter.sh)

  COMMENT_METRIC="location /${METRICS} {
    if (\$hack = 1) {return 404;}
    auth_basic \"Restricted Content\";
    auth_basic_user_file /etc/nginx/.htpasswd;
    proxy_pass http://127.0.0.1:9100/metrics;
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
    break;
  }"

  tilda "$(text 10)"
}

###################################
### Shell In A Box
###################################
shellinabox() {
  info " $(text 83) "
  apt-get install shellinabox

  cat > /etc/default/shellinabox <<EOF
# Should shellinaboxd start automatically
SHELLINABOX_DAEMON_START=1
# TCP port that shellinboxds webserver listens on
SHELLINABOX_PORT=4200
# Parameters that are managed by the system and usually should not need
# changing:
# SHELLINABOX_DATADIR=/var/lib/shellinabox
# SHELLINABOX_USER=shellinabox
# SHELLINABOX_GROUP=shellinabox
# Any optional arguments (e.g. extra service definitions).  Make sure
# that that argument is quoted.
#   Beeps are disabled because of reports of the VLC plugin crashing
#   Firefox on Linux/x86_64.
SHELLINABOX_ARGS="--no-beep --localhost-only --disable-ssl"
}
EOF

  COMMENT_SHELLBOX="location /${SHELLBOX} {
    if (\$hack = 1) {return 404;}
    auth_basic \"Restricted Content\";
    auth_basic_user_file /etc/nginx/.htpasswd;
    proxy_pass http://127.0.0.1:4200;
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
    break;
  }"

  systemctl restart shellinabox
  tilda "$(text 10)"
}

###################################
### NGINX
###################################
nginx_setup() {
  info " $(text 45) "

  mkdir -p /etc/nginx/stream-enabled/
  mkdir -p /etc/nginx/conf.d/
  rm -rf /etc/nginx/conf.d/default.conf
  touch /etc/nginx/.htpasswd
  htpasswd -nb "$USERNAME" "$PASSWORD" > /etc/nginx/.htpasswd
  openssl dhparam -out /etc/nginx/dhparam.pem 2048

  case "$SYSTEM" in
    Debian|Ubuntu)
      USERNGINX="www-data"
      ;;

    CentOS|Fedora)
      USERNGINX="nginx"
      ;;
  esac

  nginx_conf
  stream_conf
  local_conf
  random_site

  systemctl daemon-reload
  systemctl restart nginx
  nginx -s reload

  tilda "$(text 10)"
}

###################################
### http conf
###################################
nginx_conf() {
  cat > /etc/nginx/nginx.conf <<EOF
user                                   ${USERNGINX};
pid                                    /var/run/nginx.pid;
worker_processes                       auto;
worker_rlimit_nofile                   65535; 
error_log                              /var/log/nginx/error.log;
include                                /etc/nginx/modules-enabled/*.conf;
events {
  multi_accept                         on;
  worker_connections                   1024;
}

http {
  map \$request_uri \$cleaned_request_uri {
    default \$request_uri;
    "~^(.*?)(\?x_padding=[^ ]*)\$" \$1;
  }
  log_format json_analytics escape=json '{'
    '\$time_local, '
    '\$http_x_forwarded_for, '
    '\$proxy_protocol_addr, '
    '\$request_method '
    '\$status, '
    '\$http_user_agent, '
    '\$cleaned_request_uri, '
    '\$http_referer, '
    '}';
  set_real_ip_from                     127.0.0.1;
  real_ip_header                       X-Forwarded-For;
  real_ip_recursive                    on;
  access_log                           /var/log/nginx/access.log json_analytics;
  sendfile                             on;
  tcp_nopush                           on;
  tcp_nodelay                          on;
  server_tokens                        off;
  log_not_found                        off; 
  types_hash_max_size                  2048;
  types_hash_bucket_size               64;
  client_max_body_size                 16M;
  keepalive_timeout                    75s;
  keepalive_requests                   1000;
  reset_timedout_connection            on;
  include                              /etc/nginx/mime.types;
  default_type                         application/octet-stream;
  ssl_session_timeout                  1d;
  ssl_session_cache                    shared:SSL:1m;
  ssl_session_tickets                  off;
  ssl_prefer_server_ciphers            on;
  ssl_protocols                        TLSv1.2 TLSv1.3;
  ssl_ciphers                          HIGH:!aNULL:!eNULL:!MD5:!DES:!RC4:!ADH:!SSLv3:!EXP:!PSK:!DSS;
  ssl_stapling                         on;
  ssl_stapling_verify                  on;
  resolver                             127.0.0.1 valid=60s;
  resolver_timeout                     2s;
  gzip                                 on;
  add_header X-XSS-Protection          "0" always;
  add_header X-Content-Type-Options    "nosniff" always;
  add_header Referrer-Policy           "no-referrer-when-downgrade" always;
  add_header Permissions-Policy        "interest-cohort=()" always;
  add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
  add_header X-Frame-Options           "SAMEORIGIN";
  proxy_hide_header                    X-Powered-By;
  include                              /etc/nginx/conf.d/*.conf;
}
stream {
  include /etc/nginx/stream-enabled/stream.conf;
}
EOF
}

###################################
### Stream conf
###################################
stream_conf() {
  cat > /etc/nginx/stream-enabled/stream.conf <<EOF
map \$ssl_preread_server_name \$backend {
  ${DOMAIN}                            web;
  ${SUB_DOMAIN}                        xtls;
  ${REALITY}                           reality;
  default                              block;
}
upstream block {
  server 127.0.0.1:36076;
}
upstream web {
  server 127.0.0.1:7443;
}
upstream reality {
  server 127.0.0.1:8443;
}
upstream xtls {
  server 127.0.0.1:9443;
}
server {
  listen 443                           reuseport;
  ssl_preread                          on;
  proxy_protocol                       on;
  proxy_pass                           \$backend;
}
EOF
}

###################################
### Server conf
###################################
local_conf() {
  cat > /etc/nginx/conf.d/local.conf <<EOF
server {
  listen                               80;
  server_name                          ${DOMAIN} *.${DOMAIN};
  location / {
    return 301                         https://${DOMAIN}\$request_uri;
  }
}
server {
  listen                               9090 default_server;
  server_name                          ${DOMAIN} *.${DOMAIN};
  location / {
    return 301                         https://${DOMAIN}\$request_uri;
  }
}
server {
  listen                               36076 ssl proxy_protocol;
  ssl_reject_handshake                 on;
}
server {
  listen                               36077 ssl proxy_protocol;
  http2                                on;
  http3                                on;
  server_name                          ${DOMAIN} *.${DOMAIN};

  # SSL
  ssl_certificate                      /etc/letsencrypt/live/${DOMAIN}/fullchain.pem;
  ssl_certificate_key                  /etc/letsencrypt/live/${DOMAIN}/privkey.pem;
  ssl_trusted_certificate              /etc/letsencrypt/live/${DOMAIN}/chain.pem;

  # Diffie-Hellman parameter for DHE ciphersuites
  ssl_dhparam                          /etc/nginx/dhparam.pem;

  # Site
  index index.html index.htm index.php index.nginx-debian.html;
  root /var/www/html/;

  if (\$host !~* ^(.+\.)?${DOMAIN}\$ ){return 444;}
  if (\$scheme ~* https) {set \$safe 1;}
  if (\$ssl_server_name !~* ^(.+\.)?${DOMAIN}\$ ) {set \$safe "\${safe}0"; }
  if (\$safe = 10){return 444;}
  if (\$request_uri ~ "(\"|'|\`|~|,|:|--|;|%|\\$|&&|\?\?|0x00|0X00|\||\\|\{|\}|\[|\]|<|>|\.\.\.|\.\.\/|\/\/\/)"){set \$hack 1;}
  error_page 400 402 403 500 501 502 503 504 =404 /404;
  proxy_intercept_errors on;

  # PANEL
  location /${WEB_BASE_PATH} {
    if (\$hack = 1) {return 404;}
    proxy_redirect off;
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header Range \$http_range;
    proxy_set_header If-Range \$http_if_range;
    proxy_pass http://127.0.0.1:36075/${WEB_BASE_PATH};
    break;
  }
  # SUB
  location /${SUB_PATH} {
    if (\$hack = 1) {return 404;}
    proxy_redirect off;
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_pass http://127.0.0.1:36074/${SUB_PATH};
    break;
  }
  # SUB JSON
  location /${SUB_JSON_PATH} {
    if (\$hack = 1) {return 404;}  
    proxy_redirect off;
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_pass http://127.0.0.1:36074/${SUB_JSON_PATH};
    break;
  }
  # GRPC WEBSOCKET HTTPUpgrade
  location ~ ^/(?<fwdport>\d+)/(?<fwdpath>.*)\$ {
    if (\$hack = 1) {return 404;}
    client_max_body_size 0;
    client_body_timeout 1d;
    grpc_read_timeout 1d;
    grpc_socket_keepalive on;
    proxy_read_timeout 1d;
    proxy_http_version 1.1;
    proxy_buffering off;
    proxy_request_buffering off;
    proxy_socket_keepalive on;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    if (\$content_type ~* "GRPC") { grpc_pass grpc://127.0.0.1:\$fwdport\$is_args\$args; break; }
    proxy_pass http://127.0.0.1:\$fwdport\$is_args\$args;
    break;
  }
  # Node exporter
  ${COMMENT_METRIC}
  # SHELLBOX
  ${COMMENT_SHELLBOX}
  # Adguard Home
  ${COMMENT_AGH}
}
EOF
}

###################################
### Selecting a random site
###################################
random_site() {
  info " $(text 79) "
  mkdir -p /var/www/html/ /usr/local/reverse_proxy/

  cd /usr/local/reverse_proxy/ || echo "Не удалось перейти в /usr/local/reverse_proxy/"

  if [[ ! -d "simple-web-templates-main" ]]; then
      while ! wget -q --progress=dot:mega --timeout=30 --tries=10 --retry-connrefused "https://github.com/cortez24rus/simple-web-templates/archive/refs/heads/main.zip"; do
        warning " $(text 38) "
        sleep 3
      done
      unzip -q main.zip &>/dev/null && rm -f main.zip
  fi

  cd simple-web-templates-main || echo "Не удалось перейти в папку с шаблонами"

  rm -rf assets ".gitattributes" "README.md" "_config.yml"

  RandomHTML=$(ls -d */ | shuf -n1)  # Обновил для выбора случайного подкаталога
  info " $(text 80) ${RandomHTML}"

  # Если шаблон существует, копируем его в /var/www/html
  if [[ -d "${RandomHTML}" && -d "/var/www/html/" ]]; then
      echo "Копируем шаблон в /var/www/html/..."
      rm -rf /var/www/html/*  # Очищаем старую папку
      cp -a "${RandomHTML}/." /var/www/html/ || echo "Ошибка при копировании шаблона"
  else
      echo "Ошибка при извлечении шаблона!"
  fi

  cd ~
}

###################################
### Key generation
###################################
generate_keys() {
  # Генерация пары ключей X25519 с использованием xray
  local KEY_PAIR=$(/usr/local/x-ui/bin/xray-linux-amd64 x25519)
  local PRIVATE_KEY=$(echo "$KEY_PAIR" | grep "Private key:" | awk '{print $3}')
  local PUBLIC_KEY=$(echo "$KEY_PAIR" | grep "Public key:" | awk '{print $3}')

  # Возвращаем ключи в виде строки, разделенной пробелом
  echo "$PRIVATE_KEY $PUBLIC_KEY"
}

###################################
### Grpc
###################################
settings_grpc() {
  STREAM_SETTINGS_GRPC=$(cat <<EOF
{
  "network": "grpc",
  "security": "none",
  "externalProxy": [
  {
    "forceTls": "tls",
    "dest": "${DOMAIN}",
    "port": 443,
    "remark": ""
  }
  ],
  "grpcSettings": {
  "serviceName": "/2053/${CDNGRPC}",
  "authority": "${DOMAIN}",
  "multiMode": false
  }
}
EOF
  )
}

###################################
### Split
###################################
settings_split() {
  STREAM_SETTINGS_SPLIT=$(cat <<EOF
{
  "network": "splithttp",
  "security": "none",
  "externalProxy": [
  {
    "forceTls": "tls",
    "dest": "${DOMAIN}",
    "port": 443,
    "remark": ""
  }
  ],
  "splithttpSettings": {
  "path": "${CDNSPLIT}",
  "host": "",
  "headers": {},
  "scMaxConcurrentPosts": "100-200",
  "scMaxEachPostBytes": "1000000-2000000",
  "scMinPostsIntervalMs": "10-50",
  "noSSEHeader": false,
  "xPaddingBytes": "100-1000",
  "xmux": {
    "maxConcurrency": "16-32",
    "maxConnections": 0,
    "cMaxReuseTimes": "64-128",
    "cMaxLifetimeMs": 0
  },
  "mode": "auto",
  "noGRPCHeader": false
  }
}
EOF
  )
}

###################################
### Httpu
###################################
settings_httpu() {
  STREAM_SETTINGS_HTTPU=$(cat <<EOF
{
  "network": "httpupgrade",
  "security": "none",
  "externalProxy": [
  {
    "forceTls": "tls",
    "dest": "${DOMAIN}",
    "port": 443,
    "remark": ""
  }
  ],
  "httpupgradeSettings": {
  "acceptProxyProtocol": false,
  "path": "/2073/${CDNHTTPU}",
  "host": "${DOMAIN}",
  "headers": {}
  }
}
EOF
  )
}

###################################
### Ws
###################################
settings_ws() {
  STREAM_SETTINGS_WS=$(cat <<EOF
{
  "network": "ws",
  "security": "none",
  "externalProxy": [
  {
    "forceTls": "tls",
    "dest": "${DOMAIN}",
    "port": 443,
    "remark": ""
  }
  ],
  "wsSettings": {
  "acceptProxyProtocol": false,
  "path": "/2083/${CDNWS}",
  "host": "${DOMAIN}",
  "headers": {}
  }
}
EOF
  )
}

###################################
### Settings reality (Steal Oneself)
###################################
settings_steal() {
  read PRIVATE_KEY0 PUBLIC_KEY0 <<< "$(generate_keys)"
  STREAM_SETTINGS_STEAL=$(cat <<EOF
{
  "network": "tcp",
  "security": "reality",
  "externalProxy": [
  {
    "forceTls": "same",
    "dest": "${SUB_DOMAIN}",
    "port": 443,
    "remark": ""
  }
  ],
  "realitySettings": {
  "show": false,
  "xver": 2,
  "dest": "36077",
  "serverNames": [
    "${DOMAIN}"
  ],
  "privateKey": "${PRIVATE_KEY0}",
  "minClient": "",
  "maxClient": "",
  "maxTimediff": 0,
  "shortIds": [
    "22dff0",
    "0041e9ca",
    "49afaa139d",
    "89",
    "1addf92cc1bd50",
    "6e122954e9df",
    "8d93026df5de065c",
    "bc85"
  ],
  "settings": {
    "publicKey": "${PUBLIC_KEY0}",
    "fingerprint": "chrome",
    "serverName": "",
    "spiderX": "/"
  }
  },
  "tcpSettings": {
  "acceptProxyProtocol": true,
  "header": {
    "type": "none"
  }
  }
}
EOF
  )
}

###################################
### Settings reality
###################################
settings_reality() {
  read PRIVATE_KEY1 PUBLIC_KEY1 <<< "$(generate_keys)"
  STREAM_SETTINGS_REALITY=$(cat <<EOF
{
  "network": "tcp",
  "security": "reality",
  "externalProxy": [
  {
    "forceTls": "same",
    "dest": "${SUB_DOMAIN}",
    "port": 443,
    "remark": ""
  }
  ],
  "realitySettings": {
  "show": false,
  "xver": 0,
  "dest": "${REALITY}:443",
  "serverNames": [
    "${REALITY}"
  ],
  "privateKey": "${PRIVATE_KEY1}",
  "minClient": "",
  "maxClient": "",
  "maxTimediff": 0,
  "shortIds": [
    "c7c487",
    "cf",
    "248c16289e",
    "ae60608a67d1a367",
    "21221b811591",
    "648bc6ab5ba1bc",
    "73d1",
    "3028618d"
  ],
  "settings": {
    "publicKey": "${PUBLIC_KEY1}",
    "fingerprint": "chrome",
    "serverName": "",
    "spiderX": "/"
  }
  },
  "tcpSettings": {
  "acceptProxyProtocol": true,
  "header": {
    "type": "none"
  }
  }
}
EOF
  )
}

###################################
### Settings xtls
###################################
settings_xtls() {
  STREAM_SETTINGS_XTLS=$(cat <<EOF
{
  "network": "tcp",
  "security": "tls",
  "externalProxy": [
  {
    "forceTls": "same",
    "dest": "${SUB_DOMAIN}",
    "port": 443,
    "remark": ""
  }
  ],
  "tlsSettings": {
  "serverName": "${SUB_DOMAIN}",
  "minVersion": "1.3",
  "maxVersion": "1.3",
  "cipherSuites": "",
  "rejectUnknownSni": false,
  "disableSystemRoot": false,
  "enableSessionResumption": false,
  "certificates": [
    {
    "certificateFile": "/etc/letsencrypt/live/${DOMAIN}/fullchain.pem",
    "keyFile": "/etc/letsencrypt/live/${DOMAIN}/privkey.pem",
    "ocspStapling": 3600,
    "oneTimeLoading": false,
    "usage": "encipherment",
    "buildChain": false
    }
  ],
  "alpn": [
    "http/1.1"
  ],
  "settings": {
    "allowInsecure": false,
    "fingerprint": "chrome"
  }
  },
  "tcpSettings": {
  "acceptProxyProtocol": true,
  "header": {
    "type": "none"
  }
  }
}
EOF
  )
}

###################################
### Sniffing
###################################
sniffing_inbounds() {
  SNIFFING=$(cat <<EOF
{
  "enabled": true,
  "destOverride": [
    "http",
    "tls",
    "quic",
    "fakedns"
  ],
  "metadataOnly": false,
  "routeOnly": false
}
EOF
  )
}

###################################
### Changing the Database
###################################
database_change() {
  DB_PATH="x-ui.db"

  sqlite3 $DB_PATH <<EOF
UPDATE users 
SET username = '$USERNAME', password = '$PASSWORD' 
WHERE id = 1;

UPDATE inbounds SET stream_settings = '$STREAM_SETTINGS_GRPC' WHERE LOWER(remark) LIKE '%grpc%';
UPDATE inbounds SET stream_settings = '$STREAM_SETTINGS_SPLIT' WHERE LOWER(remark) LIKE '%split%';
UPDATE inbounds SET stream_settings = '$STREAM_SETTINGS_HTTPU' WHERE LOWER(remark) LIKE '%httpu%';
UPDATE inbounds SET stream_settings = '$STREAM_SETTINGS_WS' WHERE LOWER(remark) LIKE '%ws%';
UPDATE inbounds SET stream_settings = '$STREAM_SETTINGS_STEAL' WHERE LOWER(remark) LIKE '%steal%';
UPDATE inbounds SET stream_settings = '$STREAM_SETTINGS_REALITY' WHERE LOWER(remark) LIKE '%whatsapp%';
UPDATE inbounds SET stream_settings = '$STREAM_SETTINGS_XTLS' WHERE LOWER(remark) LIKE '%xtls%';

UPDATE inbounds SET sniffing = '$SNIFFING' WHERE LOWER(remark) LIKE '%grpc%';
UPDATE inbounds SET sniffing = '$SNIFFING' WHERE LOWER(remark) LIKE '%split%';
UPDATE inbounds SET sniffing = '$SNIFFING' WHERE LOWER(remark) LIKE '%httpu%';
UPDATE inbounds SET sniffing = '$SNIFFING' WHERE LOWER(remark) LIKE '%ws%';
UPDATE inbounds SET sniffing = '$SNIFFING' WHERE LOWER(remark) LIKE '%steal%';
UPDATE inbounds SET sniffing = '$SNIFFING' WHERE LOWER(remark) LIKE '%whatsapp%';
UPDATE inbounds SET sniffing = '$SNIFFING' WHERE LOWER(remark) LIKE '%xtls%';

UPDATE settings SET value = '/${WEB_BASE_PATH}/' WHERE LOWER(key) LIKE '%webbasepath%';
UPDATE settings SET value = '/${SUB_PATH}/' WHERE LOWER(key) LIKE '%subpath%';
UPDATE settings SET value = '${SUB_URI}' WHERE LOWER(key) LIKE '%suburi%';
UPDATE settings SET value = '/${SUB_JSON_PATH}/' WHERE LOWER(key) LIKE '%subjsonpath%';
UPDATE settings SET value = '${SUB_JSON_URI}' WHERE LOWER(key) LIKE '%subjsonuri%';
EOF
}

# json_rules() {
#   SUB_JSON_RULES=$(cat <<EOF
# [{"type":"field","outboundTag":"direct","domain":["keyword:xn--","keyword:ru","keyword:su","keyword:kg","keyword:by","keyword:kz","keyword:rt","keyword:yandex","keyword:avito.","keyword:2gis.","keyword:gismeteo.","keyword:livejournal."]},{"type":"field","outboundTag":"direct","domain":["domain:ru","domain:su","domain:kg","domain:by","domain:kz"]},{"type":"field","outboundTag":"direct","domain":["geosite:category-ru","geosite:category-gov-ru","geosite:yandex","geosite:vk","geosite:whatsapp","geosite:apple","geosite:mailru","geosite:github","geosite:gitlab","geosite:duckduckgo","geosite:google","geosite:wikimedia","geosite:mozilla"]},{"type":"field","outboundTag":"direct","ip":["geoip:private","geoip:ru"]}]
# EOF
#   )
# }
# UPDATE settings SET value = '${SUB_JSON_RULES}' WHERE LOWER(key) LIKE '%subjsonrules%';
#   json_rules

###################################
### Panel installation
###################################
install_panel() {
  info " $(text 46) "

  while ! wget -q --progress=dot:mega --timeout=30 --tries=10 --retry-connrefused https://github.com/cortez24rus/xui-reverse-proxy/raw/refs/heads/main/other/x-ui.gpg; do
    warning " $(text 38) "
    sleep 3
  done

  echo ${SECRET_PASSWORD} | gpg --batch --yes --passphrase-fd 0 -d x-ui.gpg > x-ui.db
  echo -e "n" | bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh) > /dev/null 2>&1

  settings_grpc
  settings_split
  settings_httpu
  settings_ws
  settings_steal
  settings_reality
  settings_xtls
  sniffing_inbounds
  database_change

  x-ui stop

  rm -rf x-ui.gpg
  rm -rf /etc/x-ui/x-ui.db.backup
  [ -f /etc/x-ui/x-ui.db ] && mv /etc/x-ui/x-ui.db /etc/x-ui/x-ui.db.backup
  mv x-ui.db /etc/x-ui/

  x-ui start
  echo -e "20\n1" | x-ui > /dev/null 2>&1
  tilda "$(text 10)"
}

###################################
### Firewall
###################################
enabling_security() {
  info " $(text 47) "
  BLOCK_ZONE_IP=$(echo ${IP4} | cut -d '.' -f 1-3).0/22

  case "$SYSTEM" in
    Debian|Ubuntu)
      ufw --force reset
      ufw allow 22/tcp
      ufw allow 443/tcp
      ufw insert 1 deny from "$BLOCK_ZONE_IP"
      ufw --force enable
      ;;

    CentOS|Fedora)
      systemctl enable --now firewalld
      firewall-cmd --permanent --zone=public --add-port=22/tcp
      firewall-cmd --permanent --zone=public --add-port=443/tcp
      firewall-cmd --permanent --zone=public --add-rich-rule="rule family='ipv4' source address='$BLOCK_ZONE_IP' reject"
      firewall-cmd --reload
      ;;
  esac

  tilda "$(text 10)"
}

###################################
### SSH
###################################
ssh_setup() {
  if [[ "${ANSWER_SSH,,}" == "y" ]]; then
    info " $(text 48) "
    sed -i -e "
      s/#Port/Port/g;
      s/Port 22/Port 22/g;
      s/#PermitRootLogin/PermitRootLogin/g;
      s/PermitRootLogin yes/PermitRootLogin prohibit-password/g;
      s/#PubkeyAuthentication/PubkeyAuthentication/g;
      s/PubkeyAuthentication no/PubkeyAuthentication yes/g;
      s/#PasswordAuthentication/PasswordAuthentication/g;
      s/PasswordAuthentication yes/PasswordAuthentication no/g;
      s/#PermitEmptyPasswords/PermitEmptyPasswords/g;
      s/PermitEmptyPasswords yes/PermitEmptyPasswords no/g;
    " /etc/ssh/sshd_config

    # Настройка баннера
    cat > /etc/motd <<EOF

################################################################################
                        WARNING: AUTHORIZED ACCESS ONLY
################################################################################

This system is for the use of authorized users only. Individuals using this
computer system without authority, or in excess of their authority, are subject
to having all of their activities on this system monitored and recorded.

Any unauthorized access or use of this system is prohibited and may be subject
to criminal and/or civil penalties. All activities on this system are logged
and monitored. By accessing this system, you agree to comply with all applicable
company policies, and you consent to the monitoring and recording of your
activities.

If you are not an authorized user, you must disconnect immediately.

Unauthorized access to this device is strictly prohibited and will be prosecuted
to the fullest extent of the law.

################################################################################

            +----------------------------------------------------+
            | █████ █████ ███████████     █████████   █████ █████|
            |░░███ ░░███ ░░███░░░░░███   ███░░░░░███ ░░███ ░░███ |
            | ░░███ ███   ░███    ░███  ░███    ░███  ░░███ ███  |
            |  ░░█████    ░██████████   ░███████████   ░░█████   |
            |   ███░███   ░███░░░░░███  ░███░░░░░███    ░░███    |
            |  ███ ░░███  ░███    ░███  ░███    ░███     ░███    |
            | █████ █████ █████   █████ █████   █████    █████   |
            |░░░░░ ░░░░░ ░░░░░   ░░░░░ ░░░░░   ░░░░░    ░░░░░    |
            +----------------------------------------------------+


EOF
    systemctl restart ssh
    tilda "$(text 10)"
  fi
}

###################################
### Installing bot
###################################
install_bot() {
  info " $(text 57) "
  bash <(curl -Ls https://github.com/cortez24rus/xui-reverse-proxy/raw/refs/heads/main/reverse_proxy_bot.sh) "$BOT_TOKEN" "$ADMIN_ID" "$DOMAIN"
  tilda "$(text 10)"
}

###################################
### Information output
###################################
data_output() {
  info " $(text 58) "
  printf '0\n' | x-ui | grep --color=never -i ':'
  echo
  out_data " $(text 59) " "https://${DOMAIN}/${WEB_BASE_PATH}/"
  out_data " $(text 60) " "${SUB_URI}user"
  if [[ $CHOISE_DNS = "2" ]]; then
    out_data " $(text 61) " "https://${DOMAIN}/${ADGUARDPATH}/login.html"
  fi
  echo
  out_data " $(text 62) " "ssh -p 22 ${USERNAME}@${IP4}"
  echo
  out_data " $(text 63) " "$USERNAME"
  out_data " $(text 64) " "$PASSWORD"
  echo
  out_data " $(text 65) " "$LOGFILE"
  tilda "$(text 10)"
}

###################################
### Downloadr webiste
###################################
download_website() {
  reading " $(text 13) " sitelink
  wget -P /var/www --mirror --convert-links --adjust-extension --page-requisites --no-parent https://${sitelink}

  rm -rf /var/www/*
  mkdir ./testdir
  wget -q -P ./testdir https://${sitelink}
  index=$(ls ./testdir)
  rm -rf ./testdir

  if [[ "$sitelink" =~ "/" ]]
  then
    sitedir=$(echo "${sitelink}" | cut -d "/" -f 1)
  else
    sitedir="${sitelink}"
  fi

  chmod -R 755 /var/www/${sitedir}
  filelist=$(find /var/www/${sitedir} -name ${index})
  slashnum=1000

  for k in $(seq 1 $(echo "$filelist" | wc -l))
  do
    testfile=$(echo "$filelist" | sed -n "${k}p")
    if [ $(echo "${testfile}" | tr -cd '/' | wc -c) -lt ${slashnum} ]
    then
      resultfile="${testfile}"
      slashnum=$(echo "${testfile}" | tr -cd '/' | wc -c)
    fi
  done

  sitedir=${resultfile#"/var/www/"}
  sitedir=${sitedir%"/${index}"}
  echo ""
}

###################################
### Create a backup of certificates
###################################
create_cert_backup() {
  local DOMAIN=$1
  local ACTION=$2 # Тип действия: "cp" или "mv"
  local TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
  local BACKUP_DIR="/etc/letsencrypt/backups/${DOMAIN}_${TIMESTAMP}"
  
  mkdir -p "${BACKUP_DIR}"
  
  $ACTION /etc/letsencrypt/live ${BACKUP_DIR}
  $ACTION /etc/letsencrypt/archive ${BACKUP_DIR}
  $ACTION /etc/letsencrypt/renewal ${BACKUP_DIR}
}

###################################
### Database change in domain
###################################
database_change_domain() {
  sqlite3 $DB_PATH <<EOF
UPDATE settings 
SET value = REPLACE(value, '$OLD_DOMAIN', '$DOMAIN') 
WHERE value LIKE '%$OLD_DOMAIN%';

UPDATE inbounds 
SET stream_settings = REPLACE(stream_settings, '$OLD_SUB_DOMAIN', '$SUB_DOMAIN') 
WHERE stream_settings LIKE '%$OLD_SUB_DOMAIN%';

UPDATE inbounds 
SET stream_settings = REPLACE(stream_settings, '$OLD_DOMAIN', '$DOMAIN') 
WHERE stream_settings LIKE '%$OLD_DOMAIN%';
EOF
}

###################################
### Change domain name
###################################
change_domain() {
  local SQL_QUERY="SELECT stream_settings FROM inbounds WHERE remark='STEAL';"
  OLD_SUB_DOMAIN=$(sqlite3 "$DB_PATH" "$SQL_QUERY" | jq -r '.externalProxy[].dest' | sort -u)
  OLD_DOMAIN=$(sqlite3 "$DB_PATH" "$SQL_QUERY" | jq -r '.realitySettings.serverNames[]' | sort -u)
  
  check_cf_token
  create_cert_backup "$OLD_DOMAIN" "mv"
  issuance_of_certificates

  database_change_domain
  sed -i -e "s/$OLD_DOMAIN/$DOMAIN/g" /etc/nginx/stream-enabled/stream.conf
  sed -i -e "s/$OLD_DOMAIN/$DOMAIN/g" /etc/nginx/conf.d/local.conf
  
  echo "$OLD_DOMAIN > $DOMAIN"
  echo "$OLD_SUB_DOMAIN > $SUB_DOMAIN"

  systemctl restart nginx
  tilda "$(text 10)"
}

###################################
### Reissue of certificates
###################################
renew_cert() {
  # Получение домена из конфигурации Nginx
  NGINX_DOMAIN=$(grep "ssl_certificate" /etc/nginx/conf.d/local.conf | head -n 1)
  NGINX_DOMAIN=${NGINX_DOMAIN#*"/live/"}
  NGINX_DOMAIN=${NGINX_DOMAIN%"/"*}

  # Проверка наличия сертификатов
  if [ ! -d /etc/letsencrypt/live/${NGINX_DOMAIN} ]; then
    check_cf_token
    issuance_of_certificates
  else
    create_cert_backup "$NGINX_DOMAIN" "cp"
    certbot renew --force-renewal
    if [ $? -ne 0 ]; then
      return 1
    fi
  fi
  
  # Перезапуск Nginx
  systemctl restart nginx
}

###################################
### Removing all escape sequences
###################################
log_clear() {
  sed -i -e 's/\x1b\[[0-9;]*[a-zA-Z]//g' "$LOGFILE"
}

###################################
### Main function
###################################
main() {
  clear
  log_entry
  read_defaults_from_file
  parse_args "$@" || show_help
  [[ ${args[skip-check]} == "false" ]] && check_root
  [[ ${args[skip-check]} == "false" ]] && check_ip
  check_operating_system
  banner_xray
  select_language
  if [ -f ${DEFAULT_FILE} ]; then
    warning " $(text 4) "
  fi
  sleep 2
  while true; do
    clear
    banner_xray
    echo "================================="
    info " $(text 85) "                      # MENU
    echo "================================="
    info " $(text 86) "                      # Install
    info " $(text 87) "                      # Steam web site
    info " $(text 88) "                      # Change domain
    info " $(text 89) "                      # Renew cert
    info " $(text 90) "                      # Disable IPv6
    info " $(text 91) "                      # Enable IPv6
    echo
    info " $(text 84) "                      # Exit
    echo "================================="
    reading " $(text 1) " CHOICE_MENU        # Choise
    tilda "$(text 10)"
    case $CHOICE_MENU in
      1)
        clear
        banner_xray
        warning_banner
        data_entry
        [[ ${args[utils]} == "true" ]] && installation_of_utilities
        [[ ${args[dns]} == "true" ]] && dns_encryption
        [[ ${args[autoupd]} == "true" ]] && setup_auto_updates
        [[ ${args[bbr]} == "true" ]] && enable_bbr
        [[ ${args[ipv6]} == "true" ]] && disable_ipv6
        [[ ${args[warp]} == "true" ]] && warp
        [[ ${args[cert]} == "true" ]] && issuance_of_certificates
        [[ ${args[mon]} == "true" ]] && monitoring
        [[ ${args[shell]} == "true" ]] && shellinabox
        write_defaults_to_file
        update_reverse_proxy
        [[ ${args[nginx]} == "true" ]] && nginx_setup
        [[ ${args[panel]} == "true" ]] && install_panel
        [[ ${args[firewall]} == "true" ]] && enabling_security
        [[ ${args[ssh]} == "true" ]] && ssh_setup
        [[ ${args[tgbot]} == "true" ]] && install_bot
        data_output
        ;;
      2)
        download_website
        ;;
      3)
        change_domain
        ;;
      4)
        renew_cert
        ;;
      5)
        disable_ipv6
        ;;
      6)
        enable_ipv6
        ;;
      0)
        clear
        break
        ;;
      *)
        warning " $(text 76) "
        ;;
    esac
    read -rp "Нажмите Enter, чтобы вернуться в меню..." dummy
  done
  log_clear
}

main "$@"
