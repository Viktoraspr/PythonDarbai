# https://www.algoexpert.io/questions/River%20Sizes


def aplankyti(matrica, i, p, lankomi=[]):

    a2 = (p == len(matrica[0])-1 or not matrica[i][p+1])
    b2 = (p == 0 or not matrica[i][p-1])
    c2 = (i == len(matrica)-1 or not matrica[i+1][p])
    d2 = (i == 0 or not matrica[i-1][p])

    if not (a2 and b2 and c2 and d2):
        if not a2 and [i, p+1] not in lankomi:
            lankomi.append([i, p+1])
        if not b2 and [i, p-1] not in lankomi:
            lankomi.append([i, p-1])
        if not c2 and [i+1, p] not in lankomi:
            lankomi.append([i+1, p])
        if not d2 and [i-1, p] not in lankomi:
            lankomi.append([i-1, p])
    return lankomi


def skaiciuoti(matrica, i, p, ilgis=1):
    matrica[i][p] = 0
    lankomi = aplankyti(matrica, i, p)
    while lankomi:
        i, p = lankomi[-1]
        matrica[i][p] = 0
        lankomi.pop()
        lankomi = aplankyti(matrica, i, p, lankomi)
        ilgis += 1

    return ilgis


def riverSizes(matrica):
    atsakymas = []
    for i in range(len(matrica)):
        for p in range(len(matrica[0])):
            if matrica[i][p] == 0:
                continue
            atsakymas.append(skaiciuoti(matrica, i, p))
    return atsakymas


matrica = [
    [1, 0, 0, 1, 0, 1, 0, 0, 1, 1, 1, 0],
    [1, 0, 1, 0, 0, 1, 1, 1, 1, 0, 1, 0],
    [0, 0, 1, 0, 1, 1, 0, 1, 0, 1, 1, 1],
    [1, 0, 1, 0, 1, 1, 0, 0, 0, 1, 0, 0],
    [1, 0, 1, 1, 0, 0, 0, 1, 1, 1, 0, 1]
]

print(riverSizes(matrica))
