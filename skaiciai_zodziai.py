def maziau_100(skaicius):
    desimtys = {2: 'twenty', 3: 'thirty', 4: 'fourty',
                5: 'fifty', 6: 'sixty', 7: 'seventy', 8: 'eithy',
                9: 'ninety'}
    bel_19 = {0: '', 1: 'one', 2: 'two', 3: 'three', 4: 'four', 5: 'five',
              6: 'six', 7: 'seven', 8: 'eigth', 9: 'nine',
              10: 'ten', 11: 'eleven', 12: 'twelve',
              13: 'thirteen', 14: 'fourteen', 15: 'fifteen',
              16: 'sixteen', 17: 'seventeen', 18: 'eithteen',
              19: 'nineteen'}

    if skaicius < 20:
        return bel_19[skaicius]

    if skaicius < 100:
        return desimtys[skaicius//10] + ' ' + bel_19[skaicius % 10]


def maziau_1000(skaicius):
    if skaicius//100 > 0:
        return maziau_100(skaicius // 100) + ' hundred ' + maziau_100(skaicius % 100)
    else:
        return maziau_100(skaicius % 100)


def skaiciuoti(skaicius):
    if skaicius == 0:
        return 'Null'
    minusas = ''
    if skaicius <= 0:
        minusas = 'minus '
    skaicius = abs(skaicius)

    big_numbers = ['', ' million ', ' billion ',
                   ' billiard ', ' trillion ', ' quadrillion ', ' quintillion ']

    result = ''
    koef = 0
    while skaicius:
        simtai = skaicius % 1000
        if simtai != 0:
            result = maziau_1000(simtai) + big_numbers[koef] + result
        skaicius //= 1000
        koef += 1

    return minusas + result


if __name__ == "__main__":
    while True:
        s = input("Prašau įvesti skaičių: ")
        try:
            s = int(s)
            print(skaiciuoti(s))
            break
        except:
            ValueError: print('Prašau įvesti teisingą skaičių.')
