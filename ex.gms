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
    


 
parameter Pd system demand /800/ ; 
 
Set Time  /1*24/;

Parameter reportNL(i ,Time), CostrepNL(Time, *), LossrepNL(Time, *), MarginalNL(Time, *);
Parameter reportMC(i ,Time), CostrepMC(Time, *), LossrepMC(Time, *), MarginalMC(Time, *);
Parameter reportML(i ,Time), CostrepML(Time, *), LossrepML(Time, *), MarginalML(Time, *);
Parameter report(i ,Time), Costrep(Time, *), Lossrep(Time, *), Marginal(Time, *);
Parameter costmin, lossmin;
 
Parameter PDem(Time) 
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
 
Loop (Time,Pd = PDem(Time);

solve EDNoloss using nlp minimizing cost; 

reportNL(i, Time) = Pg.l(i);
CostrepNL(Time, 'cost_min') = cost.l;
MarginalNL(Time, 'lambda') = balance.m;



solve ED using nlp minimizing cost; 

reportMC(i, Time) = Pg.l(i);
CostrepMC(Time, 'cost_min') = cost.l;
LossrepMC(Time, 'loss') = loss.l;
MarginalMC(Time, 'lambda') = demand.m;
costmin = cost.l;


solve ED using nlp minimizing loss; 

reportML(i, Time) = Pg.l(i);
CostrepML(Time, 'cost') = cost.l;
LossrepML(Time, 'loss_min') = loss.l;
MarginalML(Time, 'lambda') = demand.m;
lossmin = loss.l;


solve comp using nlp minimizing compromise;

report(i, Time) = Pg.l(i);
Costrep(Time, 'cost_comp') = cost.l;
Lossrep(Time, 'loss_comp') = loss.l;
Marginal(Time, 'lambda') = demand.m;

); 

display reportMC, CostrepMC, LossrepMC, MarginalMC, reportML, CostrepML, LossrepML, MarginalML, report, Costrep, Lossrep, Marginal, reportNL, CostrepNL, MarginalNL;
