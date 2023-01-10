# COVID-19 spread
# Data
```matlab
 
breakdown = false;     regione="Abruzzo";

if breakdown
    data_location = urlwrite("https://raw.githubusercontent.com/pcm-dpc/COVID-19/master/dati-regioni/dpc-covid19-ita-regioni.csv","dati.csv") ;
else
    data_location = urlwrite("https://raw.githubusercontent.com/pcm-dpc/COVID-19/master/dati-andamento-nazionale/dpc-covid19-ita-andamento-nazionale.csv","dati.csv") ;
end



dati=readtable(data_location);
delete dati.csv

if breakdown
    dati = dati(dati.denominazione_regione==regione, :);
end
dati = dati(:,{'data','totale_casi'});
dati.data = datetime(dati.data,"Format","uuuu-MM-dd ");
dati.data = dateshift(dati.data, 'start', 'day');

disp(dati)
```
```
           data            totale_casi
    ___________________    ___________

    2020-02-24T18:00:00          0    
    2020-02-25T18:00:00          0    
    2020-02-26T18:00:00          0    
    2020-02-27T18:00:00          1    
    2020-02-28T18:00:00          1    
    2020-02-29T17:00:00          2    
    2020-03-01T17:00:00          5    
    2020-03-02T18:00:00          5    
    2020-03-03T18:00:00          6    
    2020-03-04T17:00:00          7    
    2020-03-05T17:00:00          8    
    2020-03-06T17:00:00          9    
    2020-03-07T18:00:00         11    
    2020-03-08T18:00:00         17    
    2020-03-09T18:00:00         30    
    2020-03-10T18:00:00         38    
    2020-03-11T17:00:00         38    
    2020-03-12T17:00:00         84    
    2020-03-13T17:00:00         89    
    2020-03-14T17:00:00        112    
    2020-03-15T17:00:00        137    
    2020-03-16T17:00:00        176    
    2020-03-17T17:00:00        229    
```
```matlab
confirmed_cases = dati.totale_casi;
day_num = datenum(dati.data - dati.data(1));
day_date = dati.data;
delta = finite_difference(confirmed_cases);
CURRENT = day_num(end);
```
# Data fitting
```matlab
[linfit, lin_r] = fit(day_num, confirmed_cases, 'poly1');
[expfit, exp_r] = fit(day_num, confirmed_cases, 'exp1');
[logfit, log_r] = logisticFit(day_num, confirmed_cases);
```
# Plotting
```matlab
Plotting
fig_width=1500;
fig_height= 900;
```
## Linear fitting
```matlab
plot(linfit, day_num, confirmed_cases, "o")
grid on

title("Linear fit, R��="+lin_r.rsquare)
ylabel("Contagi")
xlabel("Giorni")
```

![figure_0.png](covid19-live-script_images/figure_0.png)

```matlab

disp(linfit.p1+" nuovi contagi ogni giorno")
```
```
7.818 nuovi contagi ogni giorno
```
```matlab
disp("Predicted new cases for tomorrow: "+round(linfit(CURRENT+1)-confirmed_cases(end)))
```
```
Predicted new cases for tomorrow: -92
```
## Exponential fitting
```matlab
plot(expfit, day_num, confirmed_cases, "o")
grid on

title("Exponential fit, R��="+exp_r.rsquare)
ylabel("Contagi")
xlabel("Giorni")
```

![figure_1.png](covid19-live-script_images/figure_1.png)

```matlab

disp("+"+expfit.b*100+"% nuovi contagi ogni giorno")
```
```
+25.3966% nuovi contagi ogni giorno
```
```matlab
disp("Predicted new cases for tomorrow: "+round(expfit(CURRENT+1)-confirmed_cases(end)))
```
```
Predicted new cases for tomorrow: 68
```
# Logistic fitting
```matlab
plot(logfit, day_num, confirmed_cases, "o")
grid on

title("Logistic fit, R��="+log_r.rsquare)
ylabel("Contagi")
xlabel("Giorni")
```

![figure_2.png](covid19-live-script_images/figure_2.png)

```matlab
variation=round(predint(logfit,CURRENT+1,0.95)-confirmed_cases(end));
disp("Predicted new cases for tomorrow: "+round(logfit(CURRENT+1)-confirmed_cases(end)));
```
```
Predicted new cases for tomorrow: 18
```
```matlab
disp("                                         95% confidence in range ["+variation(1) + " - "+ variation(2)+"]");
```
```
                                         95% confidence in range [2 - 34]
```
```matlab

```
# Future projections
```matlab
look_ahead_days = 1;
extended_date_set=extend_date_array(day_date,look_ahead_days);
compare=false;
error_bars=true;    confidence = 0.95;


if confidence >= 1
    confidence=1;
    disp("Confidence interval must be between 0 and 1, clipped to "+confidence)
elseif confidence <= 0
    confidence=0.001;
    disp("Confidence interval must be between 0 and 1, clipped to "+confidence)
end

figure("Name","Future projections assuming a logistic model", 'Position', [10 10 fig_width fig_height]);

%total number
subplot(1,2,1);
hold on

plot(extended_date_set,logfit(0:(CURRENT+look_ahead_days)))


grid on
grid minor
title("Future projection assuming logistic behaviour")
ylabel("Confirmed cases")
xlabel("Day")
scatter(day_date,confirmed_cases)

legend({'Logistic growth','Data points'}, "Location","best");

if compare
    plot(extended_date_set,expfit(0:(CURRENT+look_ahead_days)))
    title("Future projection logistic vs exponential")
    legend({'Logistic growth','Data points', 'Exponential growth'}, "Location","best");
end
if error_bars
    log_ci = predint(logfit,0:(CURRENT+look_ahead_days),confidence);
    plot(extended_date_set,log_ci,'LineWidth',0.001);
    legend({'Logistic growth','Data points','Lower bound','Upper bound'}, "Location","best");

end
hold off

% Derivative
subplot(1,2,2)
hold on

plot(extended_date_set,differentiate(logfit, 0:(CURRENT+look_ahead_days)));
scatter(day_date,delta);
grid on
grid minor

title("Derivative exitmation up to the next " + look_ahead_days+" days");
ylabel("New cases")
xlabel("Day")
if compare
    plot(extended_date_set,differentiate(expfit, 0:(CURRENT+look_ahead_days)));
end
if error_bars
    plot(extended_date_set, finite_difference(log_ci(:,1)));
    plot(extended_date_set, finite_difference(log_ci(:,2)));
end

hold off
```

![figure_3.png](covid19-live-script_images/figure_3.png)

```matlab

```
# Confronto col passato:

```matlab
look_ahead_days = 21;
look_behind_days = 1;

model="Logistic";

reduced_day=day_num(1:(end-look_behind_days));
reduced_cases=confirmed_cases(1:(end-look_behind_days));
extended_date_set=extend_date_array(day_date,look_ahead_days);


if model == "Logistic"
    model_current = logfit;
    model_past = logisticFit(reduced_day, reduced_cases );
else
    model_current = expfit;
    model_past = fit(reduced_day, reduced_cases, 'exp1');
end

figure("Name","Comparison of the future projections "+look_behind_days+" days ago with the projection today", 'Position', [10 10 fig_width fig_height]);

subplot(2,2,1);
hold on
plot(extended_date_set,model_current(0:(CURRENT+look_ahead_days)))
grid minor
grid on
plot(extended_date_set,model_past(0:(CURRENT+look_ahead_days)))
scatter(day_date, confirmed_cases)
title("Comparison with the projection "+look_behind_days+" days ago");
legend({'Current projection','Past projection','Data points'}, "Location","best");
hold off


subplot(2,2,2);
semilogy(extended_date_set,model_current(0:(CURRENT+look_ahead_days)))
grid minor
grid on
hold on
semilogy(extended_date_set,model_past(0:(CURRENT+look_ahead_days)))
scatter(day_date, confirmed_cases)
title("Comparison with the projection "+look_behind_days+" days ago");
legend({'Current projection','Past projection','Data points'}, "Location","best");
hold off


subplot(2,2,3);
plot(extended_date_set,differentiate(model_current, 0:(CURRENT+look_ahead_days)));
hold on
plot(extended_date_set,differentiate(model_past, 0:(CURRENT+look_ahead_days)));
hold on
scatter(day_date,delta);
title("Comparison with the derivative "+look_behind_days+" days ago");
legend({'Current projection','Past projection','Data points'}, "Location","best");
grid minor
grid on
hold off


subplot(2,2,4);
semilogy(extended_date_set,differentiate(model_current, 0:(CURRENT+look_ahead_days)));
hold on
semilogy(extended_date_set,differentiate(model_past, 0:(CURRENT+look_ahead_days)));
hold on
scatter(day_date,delta);
title("Comparison with the derivative "+look_behind_days+" days ago");
legend({'Current projection','Past projection','Data points'}, "Location","best");
grid minor
grid on
hold off
```

![figure_4.png](covid19-live-script_images/figure_4.png)

```matlab
function [difference] = finite_difference(x)
    subtract = zeros(length(x));
    subtract = subtract(:,1);
    subtract(2:end)=x(1:(end-1));
    difference = x-subtract;
end

function [date_array2] = extend_date_array(date_array, extention)
    date_array2=date_array(1):(date_array(end)+extention);
end
```
