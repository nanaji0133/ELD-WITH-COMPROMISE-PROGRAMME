Set 
     i      Generating Units      / p1*p4 / 
     coeff def of parameters    / a, b, c, Pmin, Pmax /; 

Alias (i,j);
 
table Data (i,coeff) 
 
     a       b       c       Pmin    Pmax
        
p1   0.003   2.45    105.0   150     600

p2   0.005   3.51    44.4    100     500

p3   0.006   3.89    40.6    50      300

p4   0.004   2.78    66.9    50      300;

  
 
Table B(i, j)   'loss coefficient of product of power generations of ith and jth genrator '
     p1          p2          p3        p4
        
p1   0.00003     0           0         0

p2   0           0.00009     0         0  

p3   0           0           0.00012   0

p4   0           0           0         0.00007;
    

 
* 24-hour system demand 
* 800   900   1000  1100  1250 1100  1150  1200  1350  1450  1500 1450 
* 1400  1100  1200  1200  1250 1300  1400  1450  1200  1100  950  750 
 
parameter Pd system demand /800/ ; 
 
Set Number  /1*24/;

Parameter reportNL(i ,Number), CostrepNL(Number, *), LossrepNL(Number, *), MarginalNL(Number, *);
Parameter reportMC(i ,Number), CostrepMC(Number, *), LossrepMC(Number, *), MarginalMC(Number, *);
Parameter reportML(i ,Number), CostrepML(Number, *), LossrepML(Number, *), MarginalML(Number, *);
Parameter report(i ,Number), Costrep(Number, *), Lossrep(Number, *), Marginal(Number, *);
Parameter costmin, lossmin;
 
Parameter PDem(Number) 
/ 
1  800 
2  900 
3  1000 
4  1100 
5  1250 
6  1100 
7  1150 
8  1200 
9  1350 
10 1450 
11 1500 
12 1450 
13 1400 
14 1100 
15 1200 
16 1200 
17 1250 
18 1300 
19 1400 
20 1450 
21 1200 
22 1100 
23 950 
24 750 
/; 
 
 
Variables 
     Pg(i)  power generation level in MW 
     cost   total generation cost - the objective function  
     loss   Total transmission losses in MW
     compromise  compromise value; 
 
 
Equations 
     costfn            total cost calculation 
     lossfn            total loss calculation 
     UpperLimit(i)     Maximum Generation Output 
     LowerLimit(i)     Minimum Generation Output
     balance           total generation must equal demand
     demand            total generation must equal demand and loss
     compromisefn      compromise function; 
 
costfn.. cost =e= sum(i, Data(i,'a')*Pg(i)*Pg(i) + Data(i,'b')*Pg(i) + Data(i,'c')) ; 
lossfn.. loss =e= sum((i, j), pg(i)*B(i,j)*pg(j)); 
LowerLimit(i) .. Pg(i) =g= Data(i,'Pmin') ; 
UpperLimit(i) .. Pg(i) =l= Data(i,'Pmax') ;
balance ..  sum(i, Pg(i)) =e= Pd; 
demand ..  sum(i, Pg(i)) =e= Pd + loss ;
compromisefn.. compromise =e= sqrt(sqr(cost/costmin)+ sqr(loss/lossmin)); 


model EDNoloss /costfn,Lowerlimit,Upperlimit,balance/;
model ED /costfn,Lowerlimit,Upperlimit,demand,lossfn/;
model comp /costfn,Lowerlimit,Upperlimit,demand,lossfn, compromisefn/;
 
Loop (Number,Pd = PDem(Number);

solve EDNoloss using nlp minimizing cost; 

reportNL(i, Number) = Pg.l(i);
CostrepNL(Number, 'cost_min') = cost.l;
MarginalNL(Number, 'lambda') = balance.m;



solve ED using nlp minimizing cost; 

reportMC(i, Number) = Pg.l(i);
CostrepMC(Number, 'cost_min') = cost.l;
LossrepMC(Number, 'loss') = loss.l;
MarginalMC(Number, 'lambda') = demand.m;
costmin = cost.l;


solve ED using nlp minimizing loss; 

reportML(i, Number) = Pg.l(i);
CostrepML(Number, 'cost') = cost.l;
LossrepML(Number, 'loss_min') = loss.l;
MarginalML(Number, 'lambda') = demand.m;
lossmin = loss.l;


solve comp using nlp minimizing compromise;

report(i, Number) = Pg.l(i);
Costrep(Number, 'cost_comp') = cost.l;
Lossrep(Number, 'loss_comp') = loss.l;
Marginal(Number, 'lambda') = demand.m;

); 

display reportMC, CostrepMC, LossrepMC, MarginalMC, reportML, CostrepML, LossrepML, MarginalML, report, Costrep, Lossrep, Marginal, reportNL, CostrepNL, MarginalNL;
