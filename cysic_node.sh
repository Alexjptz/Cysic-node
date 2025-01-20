#!/bin/bash

tput reset
tput civis

show_orange() {
    echo -e "\e[33m$1\e[0m"
}

show_blue() {
    echo -e "\e[34m$1\e[0m"
}

show_green() {
    echo -e "\e[32m$1\e[0m"
    echo
}

show_red() {
    echo -e "\e[31m$1\e[0m"
}

exit_script() {
    show_red "Скрипт остановлен (Script stopped)"
        echo
        exit 0
}

incorrect_option () {
    echo
    show_red "Неверная опция. Пожалуйста, выберите из тех, что есть."
    echo
    show_red "Invalid option. Please choose from the available options."
    echo
}

process_notification() {
    local message="$1"
    show_orange "$message"
    sleep 1 && echo
}

run_commands() {
    local commands="$*"

    if eval "$commands"; then
        sleep 1
        echo
        show_green "Успешно (Success)"
        echo
    else
        sleep 1
        echo
        show_red "Ошибка (Fail)"
        echo
    fi
}

print_logo () {
    echo
    show_orange "  ______ ____    ____  _______. __    ______ " && sleep 0.2
    show_orange " /      |\   \  /   / /       ||  |  /      |" && sleep 0.2
    show_orange "|  ,----' \   \/   / |   (---- |  | |  ,----'" && sleep 0.2
    show_orange "|  |       \_    _/   \   \    |  | |  |     " && sleep 0.2
    show_orange "|   ----.    |  | .----)   |   |  | |   ----." && sleep 0.2
    show_orange " \______|    |__| |_______/    |__|  \______|" && sleep 0.2
    echo
    sleep 1
}

enter_evm_address () {
    read -p "Введите адрес (EVM Enter EVM address) (0x.....): " EVM_ADDRESS
    show_green "Ваш адрес (Your address): $EVM_ADDRESS"
    sleep 2 && echo
}

stop_node () {
    if screen -r cysic -X quit; then
        sleep 1
        show_green "Успешно (Success)"
        echo
    else
        sleep 1
        show_blue "Сессия не найдена (Session doesn't exist)"
        echo
    fi
}

while true; do
    print_logo
    show_green "------ MAIN MENU ------ "
    echo "1. Подготовка (Preparation)"
    echo "2. Установка (Installation)"
    echo "3. Управление (Operational menu)"
    echo "4. Логи (Logs)"
    echo "5. Обновление (Update)"
    echo "6. Удаление (Delete)"
    echo "7. Выход (Exit)"
    echo
    read -p "Выберите опцию (Select option): " option

    case $option in
        1)
            # PREPARATION
            process_notification "Начинаем подготовку (Starting preparation)..."
            run_commands "cd $HOME && sudo apt update && sudo apt upgrade -y && apt install unzip screen nano mc"
            echo

            show_green "--- ПОГОТОВКА ЗАЕРШЕНА. PREPARATION COMPLETED ---"
            ;;
        2)
            # INSTALLATION
            process_notification "Установка (Installation)..."

            enter_evm_address

            process_notification "Начинаем (Starting)..."

            run_commands "curl -L https://github.com/cysic-labs/phase2_libs/releases/download/v1.0.0/setup_linux.sh > ~/setup_linux.sh && bash ~/setup_linux.sh $EVM_ADDRESS"
            echo

            show_green "--- УСТАНОВКА ЗАВЕРШЕНА. INSTALLATION COMPLETED ---"
            ;;
        3)
            # OPERATIONAL
            echo
            while true; do
                show_green "------ OPERATIONAL MENU ------ "
                echo "1. Зaпустить/Перезапустить (Start/Restart)"
                echo "2. Остановить (Stop)"
                echo "3. Выход (Exit)"
                echo
                read -p "Выберите опцию (Select option): " option
                echo
                case $option in
                    1)
                        process_notification "Останавливаем (Stopping)..."
                        stop_node

                        process_notification "Запускаем (Starting)..."
                        screen -dmS cysic bash -c "cd ~/cysic-verifier/ && ./start.sh"
                        ;;
                    2)
                        process_notification "Останавливаем (Stopping)..."
                        stop_node
                        ;;
                    3)
                        break
                        ;;
                    *)
                        incorrect_option
                        ;;
                esac
            done
            ;;
        4)
            # LOGI
            process_notification "Подключаемся (Connecting)..." && sleep 2
            cd $HOME && screen -r cysic
            ;;
        5)
            # UPDATE
            process_notification "Обновление (Updating)..."

            process_notification "Останавливаем (Stopping)..."

            stop_node

            process_notification "Чистим DB (Cleaning DB)..."
            run_commands "cd cysic-verifier/data && rm cysic-verifier.db"
            echo

            enter_evm_address

            process_notification "Обновляем (Updating)..."
            run_commands "curl -L https://github.com/cysic-labs/phase2_libs/releases/download/v1.0.0/setup_linux.sh > ~/setup_linux.sh && bash ~/setup_linux.sh $EVM_ADDRESS"
            echo

            process_notification "Запускаем (Starting)..."
            screen -dmS cysic bash -c "cd ~/cysic-verifier/ && ./start.sh"
            echo

            show_green "--- ОБНОВЛЕНИЕ ЗАВЕРШЕНО. UPDATING COMPLETED ---"

            show_blue "--- ПРОВЕРЬТЕ ЛОГИ. CHECK LOGS ---"
            ;;
        6)
            # DELETE
            process_notification "Удаление (Deleting)..."
            echo
            while true; do
                read -p "Удалить ноду? Delete node? (yes/no): " option

                case "$option" in
                    yes|y|Y|Yes|YES)
                        process_notification "Останавливаем (Stopping)..."
                        stop_node

                        process_notification "Чистим (Cleaning)..."
                        run_commands "rm -rvf $HOME/cysic-verifier"

                        show_green "--- НОДА УДАЛЕНА. NODE DELETED. ---"
                        break
                        ;;
                    no|n|N|No|NO)
                        process_notification "Отмена (Cancel)"
                        echo ""
                        break
                        ;;
                    *)
                        incorrect_option
                        ;;
                esac
            done
            ;;
        7)
            # EXIT
            exit_script
            ;;
        *)
            incorrect_option
            ;;
    esac
done
