# Congestion Visualization


## CUGR vs. CUGR_AES (SKY130)
<img src="./CUGR(CUGR-AES-SKY130.png" width="45%"> <img src="./CUGR_AES(CUGR_AES-SKY130).png" width="45%"> 

The left image shows the congestion heatmap for the baseCUGR algorithm while the right image is evolved `CUGR_AES` algorithm on AES design. The hotspots that `CUGR_AES` has managed to resolve are highlighted in red

## CUGR vs. CUGR_IBEX (SKY130)
<img src="./CUGR(CUGR-IBEX-SKY130).png" width="45%"> <img src="./CUGR_IBEX(CUGR-IBEX-SKY130).png" width="45%"> 

The left image shows the congestion heatmap for the base CUGR algorithm while the right image is evolved `CUGR_IBEX` algorithm on IBEX design. The hotspots that `CUGR_IBEX` has managed to resolve are highlighted in red. 

## SPR vs. SPR_AES (SKY130)
<img src="./SPR(SPR-AES-SKY130).png" width="45%"> <img src="./SPR_AES(SPR-AES-SKY130).png" width="45%"> 

The left image shows the congestion heatmap for the base SPRoute global routing algorithm. On the right side, we show `SPR_AES`. We can see that `SPR_AES` improves congestion across the entire design. 
