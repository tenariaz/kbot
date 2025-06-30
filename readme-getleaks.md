
##  Інструкція з використання

1.  Скопіювати файл `gitleaks-pre-commit.sh` до `.git/hooks/pre-commit` або створити симлінк.

2.  Зробити файл виконуваним:

    `chmod +x .git/hooks/pre-commit`

3.  Увімкнути hook:

    `git config gitleaks.enable true`

4.  Спробувати закомітити файл з тестовим Telegram Bot Token:

    `123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11`
