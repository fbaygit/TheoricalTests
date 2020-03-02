% ---------- BASIC DATE TO PROCESS ----------
x = 1: 100; % Size of the signal vector
xk = 1:41; % Size of the kernel vector
sign = diffusion1D(.5, 10, 10, x, 50); % Signal to be deconvolved
kernel = diffusion1D(.5, 10, 10, xk, 21); % Kernel signal
kernel = kernel/max(kernel); % Kernel normalization
fileName = '/Users/Felipe/Dropbox (Uniklinik Bonn)/Felipe/Accuracy Tests by intervals sums/data.xls'; % URL of exported data
iter = 10000; % Number of tests to do

tic % Initial time of execution
% ----- RESULTS -----
% Noised signals, deconvolved noised signals, noises appliyed to clear
% signals and deconvolution of noises applyed to signals
[allNoisedSignals, allNoisedSignalsDeconvolved, allNoises, allNoisesDeconvolved] = deconvolveAll(sign, kernel, iter);
% Accuracy results for every case of estimation
[centralPeaksAccuracy, neigborhoodAccuracy, wholeCurvesAccuracy] = calculateAccuracy...
    (sign, allNoisedSignalsDeconvolved,allNoisesDeconvolved);
% Average and STDs for each case of estimation
[averageCentralPeaks, averageNeighborhood, averageWholeCurve, stdCentralPeaks, stdNeighborhood, stdWholeCurve] =...
    deal (mean(centralPeaksAccuracy), mean(neigborhoodAccuracy), mean(wholeCurvesAccuracy), std(centralPeaksAccuracy),...
    std(neigborhoodAccuracy), std(wholeCurvesAccuracy));
% Plotting the tendencies and single examples of the test 
plorGraphs(sign, kernel, allNoisedSignals, allNoisedSignalsDeconvolved, allNoises, allNoisesDeconvolved, "SinglePlots", iter)
% Exporting XLS file
pos = saveXLS(fileName, "1000 Tests", ["Original Signal"; "Kernel"; "Average Central Peak Acccuracy"; "Average STD CPA";...
    "Average Neighborhood Accuracy"; "Average STD NA"; "Average Whole Curve minus Noise Deconvolution Accuracy";...
    "Average STD WCA"; "Central Peak accuracy"; "Neighborhood Accuracy";...
    "Whole Curve minus Noise Deconvolution Accuracy"; "All Noised Signals"; "All Deconvolved Signals"; "All Noises"; "All Deconvolved Noises"],...
    {sign; kernel; averageCentralPeaks; stdCentralPeaks; averageNeighborhood; stdNeighborhood; averageWholeCurve;...
    stdWholeCurve; centralPeaksAccuracy'; neigborhoodAccuracy'; wholeCurvesAccuracy'; allNoisedSignals; allNoisedSignalsDeconvolved;...
    allNoises; allNoisesDeconvolved}, 1);
toc % End time execution

% This function receives a clear signal, a kernel and a number of testa (iter) and
% returns iter number of noised signals, their deconvolution, their noise
% and their deconvolved noise
function [allNoisedSignals, allNoisedSignalsDeconvolved, allNoises, allNoisesDeconvolved] = deconvolveAll(sign, kernel, iter)
    f = waitbar(0,'Deconvolving signals...');
    allNoises = []; % All noises applyed to the signals
    allNoisedSignals = []; % All noised signals matrix after 100 tests
    allNoisedSignalsDeconvolved = []; % All deconvolved signals matrix after 100 tests
    allNoisesDeconvolved = []; % All deconvolved noise signals
    for i = 1: iter
        N = randn(1, 100)/10;
        allNoises = [allNoises; N];
        
        noisedSignal = sign + N;
        allNoisedSignals = [allNoisedSignals; noisedSignal];
        
        deconvolvedSignal = deconvlucy(noisedSignal, kernel, 1000);
        allNoisedSignalsDeconvolved = [allNoisedSignalsDeconvolved; deconvolvedSignal];
        
        deconvolvedNoise = deconvlucy(N, kernel, 1000);
        allNoisesDeconvolved = [allNoisesDeconvolved; deconvolvedNoise];
        waitbar(i/iter,f,'Deconvolving signals... ('+string(i*100/iter)+'%)');
    end
    close(f)
end

%This function receives the clear signal, the matrix with all the
%deconvolved signals and the matrix of deconvolved noises and return the
%accuracy matrices for every estimation case
function [centralPeaksAccuracy, neigborhoodAccuracy, wholeCurvesAccuracy] = calculateAccuracy...
    (sign, allNoisedSignalsDeconvolved,allNoisesDeconvolved)
    centralPeaksAccuracy = [];
    neigborhoodAccuracy = [];
    wholeCurvesAccuracy = [];
    f = waitbar(0,'Calculating Accuracy...');
    for i = 1: size(allNoisedSignalsDeconvolved, 1)
        centralPeaksAccuracy = [centralPeaksAccuracy, 100-(sum(allNoisedSignalsDeconvolved(i, 50))*100/sign(50))]; % case for central peaks
        neigborhoodAccuracy = [neigborhoodAccuracy, 100-(sum(allNoisedSignalsDeconvolved(i, 48:52))*100/sign(50))]; % Case for neighborhood estimation
        wholeCurvesAccuracy = [wholeCurvesAccuracy, 100-((sum(allNoisedSignalsDeconvolved(i, :)) - sum([allNoisesDeconvolved(i, 1:40), allNoisesDeconvolved(i, 60:100)]))*100/sign(50));]; % case for sum of deconvolved curve minus deconvolvednoise
        waitbar(i/length(allNoisedSignalsDeconvolved),f,'Calculating Accuracy... ('+string(i*100/length(allNoisedSignalsDeconvolved))+'%)');
    end
    close(f)
end

% This function receives all the data and plot the grapsh. PlotCase is the
% argument to define if the tendency plots or the single examples must be
% plotted
function plorGraphs(sign, kernel, allNoisedSignals, allNoisedSignalsDeconvolved, allNoises, allNoisesDeconvolved, plotCase, iter)
    switch plotCase
        case "Tendency"
            S = mean(allNoisedSignalsDeconvolved);
            S = S/max(S);
            S(500) = 0.14;
            plot(S)
            title(["Average of Deconvolved Noised Signals", string(iter)+" Curves", "Average normalized and central peak set to 0.14"], 'FontSize', 15)
            xlabel('Space')
            ylabel('Amplitude')
            grid on
        case "SinglePlots"
            figure;
            plot(1:100, sign, 1:41, kernel, 1:100, allNoisedSignals(1,:), 1:100, allNoisedSignalsDeconvolved(1,:))
            title("Single Noised signal deconvolution", 'FontSize', 15)
            xlabel('Space')
            ylabel('Amplitude')
            legend("Original Signal", "Kernel", "Single Noised Signal", "Single Noised Signal Deconvolution", 'FontSize', 16);
            grid on
            figure;
            plot(1:100, allNoises(1,:), 1:100, allNoisesDeconvolved(1,:))
            title("Noise signal deconvolution", 'FontSize', 15)
            xlabel('Space')
            ylabel('Amplitude')
            legend("Noise signal", "Deconvolved Noise", 'FontSize', 16);
            grid on
    end
end

% This function receives the URL of the XLS file, a string with the name of
% the page nside the XLS, a vector of strings with the headings of the data
% that contains the XLS file, a cell array that contains all the data to be
% exported, and the initial position (row) where the writing will start.
% The funtion returns the last row that was written.
function pos = saveXLS(filename, pageName, titles, data, initialPos)
    F = waitbar(0,'Please wait... Writing XLS ');
    tic
    pos = initialPos;
    for i = 1: length(data)
        writematrix(titles(i,:), filename, 'Sheet', pageName, 'Range', 'B' + string(pos))
        pos = pos + 2;
        writematrix(data{i} , filename, 'Sheet', pageName, 'Range', 'B' + string(pos))
        pos = pos + size(data{i}, 1) + 1;
        waitbar(i/length(data), F, 'Writing XLS... ('+string(i*100/length(data))+'%)');
    end
    toc
    close(F)
end

% This function calculates the clear signals according to the Fick's law
% formula. Receives time, M arguent that defines amplitude (initial mass), d that defines
% width (diffusion coeficient), x vector where the function will be
% evaluated, and desv the centre of the signal.
function dif = diffusion1D(time, M, d, x, desv)
    left = M / (2 * sqrt(pi * d * time));
    expo = exp((- ((x-desv).^2))/(4 * d * time));
    dif = left * expo;
end