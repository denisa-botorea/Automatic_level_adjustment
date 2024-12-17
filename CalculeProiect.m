%% implementarea pompei
%coeficientii pompei
k1 = 0.624;
k2 = -0.015;
k3 = -0.0006;
k = 0.024;  
%coeficientul de curgere
C = 5.6;
% pompa
k11 = k2*k2+4*(k-k3)*k1;
k12 = 8*(k-k3);
k13 = 2*(k-k3);


%treapta de la 0 ->u0 = 4.4
%valorile lui h si q in regim stationar
h0 = 13.97; 
q0 = 20.97; %val. debitului dat de pompa egala cu a debitului de iesire din rezervor

%% treapta de la u0 = 4.4 -> 4.9
%valorile lui h si q in regim stationar
h1 = 17.85;
q1 = 23.67;

%identificarea functiei de transfer
delta_h = h1-h0;
delta_ua = 4.9 - 4.4;
kp = (delta_h/3)/delta_ua %se inmulteste cu 1/3 pt ca se ia in considerare si modelul traductorului
h63 = h0 + 0.63*delta_h
Tp = 153;
H_proces = tf(kp, [Tp 1])   

%sim('bucla_deschisa.slx')
%% calcularea si implementarea unui regulator PI
T0 = Tp/4;  %s-a impus ca timpul de raspuns sa fie Tp= 153
Ho = tf(1, [T0 1])
H_pi = (1/H_proces)*(Ho/(1-Ho));
H_PI = minreal(H_pi)
[kp,ki,kd] = piddata(H_PI)


%% feed-forward
kcompensare = (delta_h/(q1-q0))/(delta_h/delta_ua)

%% cascada
%regulator PI din bucla interna
%29.02 il iau de pe graficul lui q cand am doar procesul pentru un timp de
%rulare de 6 secunde
kp_in = (29.02-q0)/delta_ua
q63 = q0 + 0.63*(29.02-q0)
Tp_in = 0.74;  %se ia de pe acelasi grafic de unde am luat val. 29.02

H_intern = tf(kp_in, [Tp_in 1]);
T0_in = Tp_in/4;  %se impune tr=4
Ho_in = tf(1, [T0_in 1]);
Hr_in = (1/H_intern)*(Ho_in/(1-Ho_in));
HPI_in = minreal(Hr_in)
[kp1, ki1, kd1] = piddata(HPI_in)

%% regulator PI din bucla externa
kp_ext = ((26.84-h0)/3)/(29.02-q0)
h63=h0+0.63*(26.84-h0)
T_ext = 554;

H_extern = tf(kp_ext, [T_ext 1])
T0_ext = Tp/4;  
Ho_ext = tf(1, [T0_ext 1]);
Hr_ext = (1/H_extern)*(Ho_ext/(1-Ho_ext))
%Hr_ext = (1/H_extern)*(Ho/(1-Ho))
HPI_ext = minreal(Hr_ext)
[kp2, ki2, kd2] = piddata(HPI_ext)