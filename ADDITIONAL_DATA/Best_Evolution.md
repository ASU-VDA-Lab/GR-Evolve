## Best % Improvement in Wirelength at Each Evolution Checkpoint

## Overall Best (All Designs / All Routers / All PDKs)

| Stage     | Router                  | Baseline WL | Best WL   | Improvement |
| --------- | ------------------------ | ----------- | --------- | ----------- |
| First 5   | CUGR_SWERV(NAN45)         | 2,799,700   | 2,556,680 | 8.68%       |
| First 10  | CUGR_SWERV(NAN45)         | 2,799,700   | 2,555,130 | 8.74%       |
| First 25  | CUGR_SWERV(NAN45)         | 2,799,700   | 2,548,142 | 8.99%       |
| First 50  | SPR_IBEX(SKY130)          | 700,100     | 652,193   | 6.84%       |
| First 75  | CUGR_IBEX(NAN45)          | 263,400     | 253,878   | 3.62%       |
| First 100 | CUGR_IBEX(NAN45)          | 263,400     | 253,361   | 3.81%       |

---

## Per Design

### AES

| Stage     | Router            | Baseline WL | Best WL | Improvement |
| --------- | ------------------ | ----------- | ------- | ----------- |
| First 5   | CUGR_AES(NAN45)     | 263,200     | 254,604 | 3.27%       |
| First 10  | CUGR_AES(NAN45)     | 263,200     | 251,277 | 4.53%       |
| First 25  | CUGR_AES(NAN45)     | 263,200     | 251,277 | 4.53%       |
| First 50  | CUGR_AES(NAN45)     | 263,200     | 251,277 | 4.53%       |
| First 75  | CUGR_AES(ASAP7)     | 62,600      | 62,362  | 0.38%       |
| First 100 | FR_AES(ASAP7)       | 63,200      | 62,554  | 1.02%       |

### IBEX

| Stage     | Router              | Baseline WL | Best WL | Improvement |
| --------- | -------------------- | ----------- | ------- | ----------- |
| First 5   | SPR_IBEX(SKY130)      | 700,100     | 652,211 | 6.84%       |
| First 10  | SPR_IBEX(SKY130)      | 700,100     | 652,193 | 6.84%       |
| First 25  | SPR_IBEX(SKY130)      | 700,100     | 652,193 | 6.84%       |
| First 50  | SPR_IBEX(SKY130)      | 700,100     | 652,193 | 6.84%       |
| First 75  | CUGR_IBEX(NAN45)      | 263,400     | 253,878 | 3.62%       |
| First 100 | CUGR_IBEX(NAN45)      | 263,400     | 253,361 | 3.81%       |

### JPEG

| Stage     | Router             | Baseline WL | Best WL   | Improvement |
| --------- | ------------------- | ----------- | --------- | ----------- |
| First 5   | FR_JPEG(SKY130)      | 1,254,200   | 1,222,092 | 2.56%       |
| First 10  | FR_JPEG(SKY130)      | 1,254,200   | 1,222,092 | 2.56%       |
| First 25  | FR_JPEG(SKY130)      | 1,254,200   | 1,222,092 | 2.56%       |
| First 50  | FR_JPEG(SKY130)      | 1,254,200   | 1,222,092 | 2.56%       |
| First 75  | FR_JPEG(SKY130)      | 1,254,200   | 1,222,092 | 2.56%       |
| First 100 | CUGR_JPEG(ASAP7)     | 153,400     | 153,400   | 0.00%       |

### SWERV

| Stage     | Router             | Baseline WL | Best WL   | Improvement |
| --------- | ------------------- | ----------- | --------- | ----------- |
| First 5   | CUGR_SWERV(NAN45)    | 2,799,700   | 2,556,680 | 8.68%       |
| First 10  | CUGR_SWERV(NAN45)    | 2,799,700   | 2,555,130 | 8.74%       |
| First 25  | CUGR_SWERV(NAN45)    | 2,799,700   | 2,548,142 | 8.99%       |
### DYNAMIC_NODE

| Stage     | Router            | Baseline WL | Best WL | Improvement |
| --------- | ------------------ | ----------- | ------- | ----------- |
| First 5   | CUGR_DN(NAN45)      | 203,600     | 199,348 | 2.09%       |
| First 10  | CUGR_DN(NAN45)      | 203,600     | 199,263 | 2.13%       |
| First 25  | SPR_DN(ASAP7)       | 62,200      | 62,106  | 0.15%       |

### ARIANE136

| Stage     | Router               | Baseline WL | Best WL   | Improvement |
| --------- | --------------------- | ----------- | --------- | ----------- |
| First 5   | CUGR_AR136(NAN45)      | 8,070,100   | 7,670,071 | 4.96%       |
| First 10  | CUGR_AR136(NAN45)      | 8,070,100   | 7,631,281 | 5.44%       |
| First 25  | CUGR_AR136(NAN45)      | 8,070,100   | 7,496,559 | 7.11%       |

### BLACK_PARROT

| Stage     | Router             | Baseline WL | Best WL   | Improvement |
| --------- | ------------------- | ----------- | --------- | ----------- |
| First 5   | CUGR_BP(NAN45)       | 6,855,400   | 6,781,103 | 1.08%       |
| First 10  | CUGR_BP(NAN45)       | 6,855,400   | 6,768,812 | 1.26%       |
| First 25  | FR_BP(NAN45)         | 6,325,900   | 6,325,532 | 0.01%       |

---

## Per Router

### FastRoute (FR)

| Stage     | Router            | Baseline WL | Best WL   | Improvement |
| --------- | ------------------ | ----------- | --------- | ----------- |
| First 5   | FR_JPEG(SKY130)     | 1,254,200   | 1,222,092 | 2.56%       |
| First 10  | FR_JPEG(SKY130)     | 1,254,200   | 1,222,092 | 2.56%       |
| First 25  | FR_JPEG(SKY130)     | 1,254,200   | 1,222,092 | 2.56%       |
| First 50  | FR_JPEG(SKY130)     | 1,254,200   | 1,222,092 | 2.56%       |
| First 75  | FR_JPEG(SKY130)     | 1,254,200   | 1,222,092 | 2.56%       |
| First 100 | FR_AES(ASAP7)       | 63,200      | 62,554    | 1.02%       |

### CUGR

| Stage     | Router             | Baseline WL | Best WL   | Improvement |
| --------- | ------------------- | ----------- | --------- | ----------- |
| First 5   | CUGR_SWERV(NAN45)    | 2,799,700   | 2,556,680 | 8.68%       |
| First 10  | CUGR_SWERV(NAN45)    | 2,799,700   | 2,555,130 | 8.74%       |
| First 25  | CUGR_SWERV(NAN45)    | 2,799,700   | 2,548,142 | 8.99%       |
| First 50  | CUGR_AES(NAN45)      | 263,200     | 251,277   | 4.53%       |
| First 75  | CUGR_IBEX(NAN45)     | 263,400     | 253,878   | 3.62%       |
| First 100 | CUGR_IBEX(NAN45)     | 263,400     | 253,361   | 3.81%       |

### SPRoute (SPR)

| Stage     | Router              | Baseline WL | Best WL | Improvement |
| --------- | -------------------- | ----------- | ------- | ----------- |
| First 5   | SPR_IBEX(SKY130)      | 700,100     | 652,211 | 6.84%       |
| First 10  | SPR_IBEX(SKY130)      | 700,100     | 652,193 | 6.84%       |
| First 25  | SPR_IBEX(SKY130)      | 700,100     | 652,193 | 6.84%       |
| First 50  | SPR_IBEX(SKY130)      | 700,100     | 652,193 | 6.84%       |
| First 75  | SPR_IBEX(NAN45)       | 259,300     | 253,646 | 2.18%       |
| First 100 | SPR_IBEX(NAN45)       | 259,300     | 253,642 | 2.18%       |

---

## Per PDK

### Nangate45

| Stage     | Router             | Baseline WL | Best WL   | Improvement |
| --------- | ------------------- | ----------- | --------- | ----------- |
| First 5   | CUGR_SWERV(NAN45)    | 2,799,700   | 2,556,680 | 8.68%       |
| First 10  | CUGR_SWERV(NAN45)    | 2,799,700   | 2,555,130 | 8.74%       |
| First 25  | CUGR_SWERV(NAN45)    | 2,799,700   | 2,548,142 | 8.99%       |
| First 50  | CUGR_AES(NAN45)      | 263,200     | 251,277   | 4.53%       |
| First 75  | CUGR_IBEX(NAN45)     | 263,400     | 253,878   | 3.62%       |
| First 100 | CUGR_IBEX(NAN45)     | 263,400     | 253,361   | 3.81%       |

### ASAP7

| Stage     | Router             | Baseline WL | Best WL | Improvement |
| --------- | ------------------- | ----------- | ------- | ----------- |
| First 5   | SPR_IBEX(ASAP7)      | 92,400      | 91,591  | 0.88%       |
| First 10  | SPR_IBEX(ASAP7)      | 92,400      | 91,591  | 0.88%       |
| First 25  | SPR_JPEG(ASAP7)      | 153,200     | 151,582 | 1.06%       |
| First 50  | SPR_JPEG(ASAP7)      | 153,200     | 151,582 | 1.06%       |
| First 75  | SPR_JPEG(ASAP7)      | 153,200     | 151,582 | 1.06%       |
| First 100 | FR_AES(ASAP7)        | 63,200      | 62,554  | 1.02%       |

### SKY130

| Stage     | Router             | Baseline WL | Best WL   | Improvement |
| --------- | ------------------- | ----------- | --------- | ----------- |
| First 5   | SPR_IBEX(SKY130)     | 700,100     | 652,211   | 6.84%       |
| First 10  | SPR_IBEX(SKY130)     | 700,100     | 652,193   | 6.84%       |
| First 25  | SPR_IBEX(SKY130)     | 700,100     | 652,193   | 6.84%       |
| First 50  | SPR_IBEX(SKY130)     | 700,100     | 652,193   | 6.84%       |
| First 75  | FR_JPEG(SKY130)      | 1,254,200   | 1,222,092 | 2.56%       |
| First 100 | FR_AES(SKY130)       | 780,200     | 778,065   | 0.27%       |
