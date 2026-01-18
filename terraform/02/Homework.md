# Задание 1

## Упражнение 1
<img width="1757" height="102" alt="1" src="https://github.com/user-attachments/assets/dc3b2944-9c71-4d47-879e-5cb8538be4c7" />

## Упражнение 2
<img width="533" height="66" alt="2" src="https://github.com/user-attachments/assets/f4c1e678-ce1c-450e-8e42-0eac0dbf418c" />

## Упражнение 3

1. Unsupported terraform core version - Моя версия terraform 1.13 и выше, в проекте 1.12

2: 
│ Error: Invalid function argument
│ 
│   on providers.tf line 15, in provider "yandex":
│   15:   service_account_key_file = file("~/.authorized_key.json")

добавить путь к service_account_key_file

3:
│ Error: Error while requesting API to create network: client-request-id = 17cd3d8a-759e-4de3-840f-d9127b196147 client-trace-id = fb51cfb1-7c0f-4169-b1d1-783abbd44868 rpc error: code = ResourceExhausted desc = Quota limit vpc.networks.count exceeded

Лимит виртуальных сетей на учетной записи исчерпан - удалил лишние и заработало

4:
│ Error: Error while requesting API to create instance: client-request-id = 4206bf9b-1240-4b67-90f5-178e9789d489 client-trace-id = 7913bba0-f40d-4926-a9fe-d8df17860586 rpc error: code = FailedPrecondition desc = Platform "standart-v4" not found

Ошибка в названии, не standart, а standard, а так же v4 я не нашел, использовал v3, и добавил zone: ru-central1-a

5: │ Error: Error while requesting API to create instance: client-request-id = 42eee6f5-0f4d-4df6-9717-fe0d151a53ff client-trace-id = 72554ab5-b067-4e5b-a0ee-d265c28eb3bc rpc error: code = InvalidArgument desc = the specified core fraction is not available on platform "standard-v3"; allowed core fractions: 20, 50, 100

Изменил деления ядер на 20% по стандарту v3

6: │ Error: Error while requesting API to create instance: client-request-id = d8467fe1-1e09-491a-bfb6-010cf246ba45 client-trace-id = 67054097-f5c7-4099-89fc-59391c07e9a7 rpc error: code = InvalidArgument desc = the specified number of cores is not available on platform "standard-v3"; allowed core number: 2, 4

Так же изменил количество ядер по стандарту

7. Ответьте, как в процессе обучения могут пригодиться параметры preemptible = true и core_fraction=5 в параметрах ВМ.
preemtible -прерываемая вм, сильно дешевле, core_fraction=5 - чем меньше ядер, тем дешевле.

# Задание 4
<img width="1076" height="210" alt="4" src="https://github.com/user-attachments/assets/d45f9cc6-ede7-49df-a139-81d127db1649" />

# Задание 7
<img width="1007" height="144" alt="{9EEB2761-AFC8-4C5F-AF06-2B4CC9D18D79}" src="https://github.com/user-attachments/assets/83d26c69-3ae5-45ac-a5e1-78fa35d54fd6" />
<img width="1004" height="560" alt="{C75AA1F2-65D3-4380-AF55-44075D97263F}" src="https://github.com/user-attachments/assets/2ed0a2ac-833f-47ea-b983-acdd4aebe85e" />

# Задание 8
<img width="672" height="68" alt="{434928C3-123B-4385-B32F-842752A65DBA}" src="https://github.com/user-attachments/assets/11eb04ad-5125-4901-a5c2-4b1bd56d0b63" />
<img width="722" height="544" alt="{12D09A28-A9E1-4C66-900E-5C85520D1757}" src="https://github.com/user-attachments/assets/0340d186-54f6-4b06-9be4-d8181396ac0d" />

# Задание 9
<img width="767" height="376" alt="{D1109225-1E4D-4590-898E-016028018531}" src="https://github.com/user-attachments/assets/e90fee6a-ba2d-45c7-8ec2-137cb2685244" />
