<h2>Роль для установки LNMP-стека уже готового для установки Wordpress, для CentOS 7/8</h2>

<i>Для разных тестовых целей. После выполнения роли можно сразу заходить браузером и запускать установку WP в уже созданную базу.</i>
<i>При запуске интерактивно запрашивается какую версию PHP ставить.</i>

Что делает:

1) Интерактивно запрашивает какую версию PHP ставить и какой пароль root для MySQL поставить
2) Готовит систему, обновляет пакеты, кое-что ставит
3) Устанавливает Nginx, подменяет конфиг (минимальный для просто обработки PHP), запускает службу
4) Подключает репозиторий remi, ставит PHP-FPM той версии которую просили и доп. пакеты к нему, подменяет конфиг и запускает службу
5) Подключает репозиторий MariaDB, устанавливает ее, запускает, меняет пароль root
6) Качает последнюю версию Wordpress в каталог сайта, распаковывает, перемещает как надо

После выполнения заходим браузером на адрес хоста, запускает установщик Wordpress. Указываем базу wordpress и тот пароль рута, который задавали ранее.
