% ---------- BASIC DATE TO PROCESS ----------
x = 1: 100; % Size of the signal vector
xk = 1:41; % Size of the kernel vector
kernel = diffusion1D(.5, 10, 10, xk, 21); % Kernel signal
kernel = kernel/max(kernel); % Kernel normalization
clearSignals = []; % All clear sgnals
for i = 7: 13
    sign = diffusion1D(.5, 10, i, x, 50); % Clear sgns with different width
    clearSignals = [clearSignals; sign/max(sign)*1.5];
end
fileName = 'D:\Dropbox (Uniklinik Bonn)\Felipe\Width Ratio Test\data2.xls';  % URL of exported data
iter = 1000; % Number of tests to do

tic % Initial time of execution
% ----- RESULTS -----
% Noised signals, deconvolved noised signals, noises appliyed to clear
% signals and deconvolution of noises applyed to signals
[allNoisedSignals, allNoisedSignalsDeconvolved, allNoises, allNoisesDeconvolved] = getAllDeconvolutions(clearSignals, kernel, iter);
% Avreage results for each case of estimation, the complete results for
% every case of estimation and their STD
[averageCentralPeaksAccuracy, averageNeigborhoodAccuracy, averageWholeCurvesAccuracy, ...
    centralPeaksAccuracy, neigborhoodAccuracy, wholeCurvesAccuracy, stdCentralPeaksAccuracy,...
    stdNeighborhoodAccuracy, stdWholeCurveAccuracy] = calculateAccuracy...
    (clearSignals, allNoisedSignalsDeconvolved, allNoisesDeconvolved, iter);
% Plotting the tendencies and single examples of the test 
plorGraphs(clearSignals, kernel, allNoisedSignals, allNoisedSignalsDeconvolved, allNoises, allNoisesDeconvolved, "SinglePlots", iter)
plorGraphs(clearSignals, kernel, allNoisedSignals, allNoisedSignalsDeconvolved, allNoises, allNoisesDeconvolved, "Tendency", iter)
% Exporting XLS file 
pos = saveXLS(fileName, string(iter)+" Tests", ["Original Signals"; "Kernel"; "Average Central Peak Accuracy";...
    "Standard Deviation CPA"; "Average Neighborhood Accuracy"; "Standard Deviation NA";...
    "Average Whole Curve minus Noise Deconvolution Accuracy"; "Standard Deviation WCA"],...
    {clearSignals; kernel; averageCentralPeaksAccuracy; stdCentralPeaksAccuracy; averageNeigborhoodAccuracy;...
    stdNeighborhoodAccuracy; averageWholeCurvesAccuracy; stdWholeCurveAccuracy}, 1);
allNoisedSignalsDeconvolved(i:i+iter-1, 1:100);
cont = 1;
for i = 1: iter: 5*iter
    pos = saveXLS(fileName, string(iter)+" Tests", ["-------------- Signal No. "+string(cont)+" --------------"; "Central Peak accuracy";...
        "Neighborhood Accuracy"; "Whole Curve minus Noise Deconvolution Accuracy"; "All Noised Signals"; "All Deconvolved Signals";...
        "All Noises"; "All Deconvolved Noises"],...
        {[]; centralPeaksAccuracy(i:i+iter-1)'; neigborhoodAccuracy(i:i+iter-1)'; wholeCurvesAccuracy(i:i+iter-1)';...
        allNoisedSignals(i:i+iter-1, 1:100); allNoisedSignalsDeconvolved(i:i+iter-1, 1:100); allNoises(i:i+iter-1, 1:100);...
        allNoisesDeconvolved(i:i+iter-1, 1:100)}, pos);
    cont = cont + 1;
end
toc % End time execution

% This function receives a vector of clear signals, the kernel signal and
% the number of tests iter, and returns a matrix that contains all the
% noised signals, their deconvolution, the noises applyed, and the
% deconvolution of the noises.
function [allNoisedSignals, allNoisedSignalsDeconvolved, allNoises, allNoisesDeconvolved] = getAllDeconvolutions(clearSignals, kernel, iter)
    f = waitbar(0,'Deconvolving signals...(0%)');
    allNoises = []; % All noises applyed to the signals
    allNoisedSignals = []; % All noised signals matrix after 100 tests
    allNoisedSignalsDeconvolved = []; % All deconvolved signals matrix after 100 tests
    allNoisesDeconvolved = []; % All deconvolved noise signals
    for i = 1: 7
        [noisedSignals, noisedSignalsDeconvolved, noises, noisesDeconvolved] = deconvolveWidthRatio(clearSignals(i, :), kernel, iter);
        allNoises = [allNoises; noises];
        allNoisedSignals = [allNoisedSignals; noisedSignals];
        allNoisedSignalsDeconvolved = [allNoisedSignalsDeconvolved; noisedSignalsDeconvolved];
        allNoisesDeconvolved = [allNoisesDeconvolved; noisesDeconvolved];
        waitbar(i/7,f,'Deconvolving signals ('+string(i)+')... ('+string(i*100/7)+'%)');
    end
    close(f)
end

% This function is called by the function above and do iter deconvolutions
% of the clear signal received. returns the matrix of noised signals, the
% noises applyed, the deconvolution of that signals and noises.
function [noisedSignals, noisedSignalsDeconvolved, noises, noisesDeconvolved] = deconvolveWidthRatio(clearSignal, kernel, iter)
    noises = []; % Noises applyed to the signals
    noisedSignals = []; % Noised signals matrix. Signals + Noise
    noisedSignalsDeconvolved = []; % Deconvolved signals matrix
    noisesDeconvolved = []; % Deconvolved noise signals
    f = waitbar(0,'Deconvolving signals...(0%)');
    for i = 1: iter
        N = randn(1, 100)/10;
        noises = [noises; N];
        
        noisedSignal = clearSignal + N;
        noisedSignals = [noisedSignals; noisedSignal];
        
        deconvolvedSignal = deconvlucy(noisedSignal, kernel, 1000);
        noisedSignalsDeconvolved = [noisedSignalsDeconvolved; deconvolvedSignal];
        
        deconvolvedNoise = deconvlucy(N, kernel, 1000);
        noisesDeconvolved = [noisesDeconvolved; deconvolvedNoise];
        waitbar(i/iter,f,'Deconvolving signals... ('+string(i*100/iter)+'%)');
    end
    close(f)
end

% this function receives the data obtained and returns the accuracy
% matrixes, the averagefor each estimation case and their STD. Give that
% all the deconvolutions of all the different SNR signals are saved into
% the same matrix, the accuracy calculation must be done, fragmenting that
% matrix, and calculate aerages and STDs for each portion of the whole
% matrix
function [averageCentralPeaksAccuracy, averageNeigborhoodAccuracy, averageWholeCurvesAccuracy, ...
    centralPeaksAccuracy, neigborhoodAccuracy, wholeCurvesAccuracy, stdCentralPeaksAccuracy,...
    stdNeighborhoodAccuracy, stdWholeCurveAccuracy] = calculateAccuracy...
    (clearSignals, allNoisedSignalsDeconvolved, allNoisesDeconvolved, iter)
    % Varable initialization
    [averageCentralPeaksAccuracy, averageNeigborhoodAccuracy, averageWholeCurvesAccuracy, centralPeaksAccuracy,...
       neigborhoodAccuracy, wholeCurvesAccuracy, curveNumber, tempCentralPeaksAccuracy, tempNeigborhoodAccuracy,...
       tempoWholeCurvesAccuracy] = deal([], [], [], [], [], [], 1, 0, 0, 0);
    % Positions to segmentate the matrix received
    [i1, i2, i3, i4, i5, i6, i7] = deal (iter, iter*2, iter*3, iter*4, iter*5, iter*6, iter*7);
    f = waitbar(0,'Calculating Accuracy...(0%)');
    for i = 1: size(allNoisedSignalsDeconvolved, 1)
        % This cascade of if statement establish which fragment of the
        % matrix is evaluated in every iteration, to determine which
        % amplitude case is being evaluated
        if i <= i1
            curveNumber = 1;
        elseif i > i1 && i <= i2
            curveNumber = 2;
        elseif i > i2 && i <= i3
            curveNumber = 3;
        elseif i > i3 && i <= i4
            curveNumber = 4;
        elseif i > i4 && i <= i5
            curveNumber = 5;
        elseif i > i5 && i <= i6
            curveNumber = 6;
        elseif i > i6 && i <= i7
            curveNumber = 7;
        end
        %Each one of the estimations cases are calculated and saved into
        %auxiliar sums to determine the average
        tempCentralPeaksAccuracy = tempCentralPeaksAccuracy + 100-(sum(allNoisedSignalsDeconvolved(i, 50))*100/clearSignals(curveNumber, 50));
        tempNeigborhoodAccuracy = tempNeigborhoodAccuracy + 100-(sum(allNoisedSignalsDeconvolved(i, 48:52))*100/clearSignals(curveNumber, 50));
        tempoWholeCurvesAccuracy = tempoWholeCurvesAccuracy + 100-((sum(allNoisedSignalsDeconvolved(i, :)) - sum([allNoisesDeconvolved(i, 1:43), allNoisesDeconvolved(i, 57:100)]))*100/clearSignals(curveNumber, 50));
        centralPeaksAccuracy = [centralPeaksAccuracy, 100-(sum(allNoisedSignalsDeconvolved(i, 50))*100/clearSignals(curveNumber, 50))];
        neigborhoodAccuracy = [neigborhoodAccuracy, 100-(sum(allNoisedSignalsDeconvolved(i, 48:52))*100/clearSignals(curveNumber, 50))];
        wholeCurvesAccuracy = [wholeCurvesAccuracy, 100-((sum(allNoisedSignalsDeconvolved(i, :)) - sum([allNoisesDeconvolved(i, 1:43), allNoisesDeconvolved(i, 57:100)]))*100/clearSignals(curveNumber, 50))];
        
        % Finishing the segment of te matrix corresponding to every
        % amplitude case, the average is calculated, and the auxiliar
        % variables are reinitialized
        if ismembertol(i, [i1, i2, i3, i4, i5, i6, i7])
            averageCentralPeaksAccuracy = [averageCentralPeaksAccuracy, tempCentralPeaksAccuracy/iter];
            averageNeigborhoodAccuracy = [averageNeigborhoodAccuracy, tempNeigborhoodAccuracy/iter];
            averageWholeCurvesAccuracy = [averageWholeCurvesAccuracy, tempoWholeCurvesAccuracy/iter];
            tempCentralPeaksAccuracy = 0;
            tempNeigborhoodAccuracy = 0;
            tempoWholeCurvesAccuracy = 0;
            
        end
        waitbar(i/size(allNoisedSignalsDeconvolved,1),f,'Calculating Accuracy... ('+string(i*100/size(allNoisedSignalsDeconvolved, 1))+'%)');
    end
    close(f)
    
    % Now, STD is calculated
    f = waitbar(0,'Calculating Standard Deviations...(0%)');
    [stdCentralPeaksAccuracy, stdNeighborhoodAccuracy, stdWholeCurveAccuracy] = deal([], [], []);
    for i = 1: iter: 7*iter
        stdCentralPeaksAccuracy = [stdCentralPeaksAccuracy, std(centralPeaksAccuracy(i:i+iter-1))];
        stdNeighborhoodAccuracy = [stdNeighborhoodAccuracy, std(neigborhoodAccuracy(i:i+iter-1))];
        stdWholeCurveAccuracy = [stdWholeCurveAccuracy, std(wholeCurvesAccuracy(i:i+iter-1))];
        waitbar(i/7*iter,f,'Calculating Standard Deviations... ('+string(i*100/7*iter)+'%)');
    end
    close(f)
end

% This function receives all the data and plot the grapsh. PlotCase is the
% argument to define if the tendency plots or the single examples must be
% plotted
function plorGraphs(clearSignals, kernel, allNoisedSignals, allNoisedSignalsDeconvolved, allNoises, allNoisesDeconvolved, plotCase, iter)
    percentages = ["-30%", "-20%", "-10%", "0%", "10%", "20%", "30%"];
    switch plotCase
        case "Tendency"
            cont = 1;
            for i = 1: iter: 7*iter
                figure;
                S = mean(allNoisedSignalsDeconvolved(i:i+iter-1, 1:100));
                plot(S)
                title(["Average of Deconvolved Noised Signals", string(iter)+" Curves", "Width Variation = "+percentages(cont)], 'FontSize', 15)
                xlabel('Space')
                ylabel('Amplitude')
                grid on
                cont = cont + 1;
            end
        case "SinglePlots"
            cont = 1;
            for i = 1: iter: 7*iter
                figure;
                plot(1:100, clearSignals(cont,:), 1:41, kernel, 1:100, allNoisedSignals(i,:), 1:100, allNoisedSignalsDeconvolved(i,:))
                title(["Single Noised Signal Deconvolution", "Width Variation = "+percentages(cont)], 'FontSize', 15)
                xlabel('Space')
                ylabel('Amplitude')
                legend("Original Signal", "Kernel", "Single Noised Signal", "Single Noised Signal Deconvolution", 'FontSize', 16);
                grid on
                cont = cont + 1;
            end
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
    pos = initialPos;
    for i = 1: length(data)
        writematrix(titles(i,:), filename, 'Sheet', pageName, 'Range', 'B' + string(pos))
        pos = pos + 2;
        writematrix(data{i} , filename, 'Sheet', pageName, 'Range', 'B' + string(pos))
        pos = pos + size(data{i}, 1) + 1;
        waitbar(i/length(data), F, 'Writing XLS... ('+string(i*100/length(data))+'%)');
    end
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