f = waitbar(0,'Please wait...');
% ---------- BASIC DATE TO PROCESS ----------
x = 1: 100; % Size of the signal vector
xk = 1:41; % Size of the kernel vector
kernel = diffusion1D(.5, 10, 10, xk, 21); % Kernel signal
kernel = kernel/max(kernel); % Kernel normalization
 
% ---------- TESTS ----------
% ----- Peaks and range tests -----
originalSignals = [];
deconvolvedClearSignals = [];
for i = 3: 14
    sign = diffusion1D(.5, i, 10, x, 50);
    dec = deconvlucy(sign, kernel, 1000);
    originalSignals = [originalSignals; sign];
    deconvolvedClearSignals = [deconvolvedClearSignals; dec];
end
[resultsClear, ~] = SNRTests(originalSignals, deconvolvedClearSignals, [], 0);
filename = '/Users/Felipe/Desktop/SNR Results/SNRTest.xlsx';
pos = saveXLS(filename, 1, ["Original Signals"; "Kernel"; "Deconvolved Signals"; "Clear Results"],...
    {originalSignals; kernel; deconvolvedClearSignals; resultsClear}, 1);
% plotResults(originalSignals, kernel, deconvolvedClearSignals)
 
allNoisedSignals = []; % All noised signals matrix
allDeconvolvedNoisedSignals = []; % All deconvolved signals matrix
allResultsNoisedNeighbors = []; % All the Accuracy Results for Noised Deconvolutions
allResultWholeNoised = [];
for t=1 : 100
    noisedSignals = [];
    deconvsNoised = [];
    deconvolvedNoises = [];
    for i = 3: 14
       N = randn(1, 100)/10;
       noised = originalSignals(i-2, :) + N; % Noised signal = signal + random noise
       noisedSignals = [noisedSignals; noised];
       dec = deconvlucy(noised, kernel, 1000);
       deconvsNoised = [deconvsNoised; dec];
       dec = deconvlucy(N, kernel, 1000);
       deconvolvedNoises = [deconvolvedNoises; dec];
    end
    allNoisedSignals = [allNoisedSignals; noisedSignals];
    allDeconvolvedNoisedSignals = [allDeconvolvedNoisedSignals; deconvsNoised];
    
    [neighborsResult, wholeCurveResult] = SNRTests(originalSignals, deconvsNoised, deconvolvedNoises, 1);
    allResultsNoisedNeighbors = [allResultsNoisedNeighbors; neighborsResult];
    allResultWholeNoised = [allResultWholeNoised; wholeCurveResult];
    
    waitbar(t/100, f, 'Executing... ('+string(t)+'%)');
    if ismembertol(t, [1, 50, 99])
        plotResults(noisedSignals, kernel, deconvsNoised)
    end
end
meanNeighbors = mean(allResultsNoisedNeighbors, 1);
meanWholeCurve = mean(allResultWholeNoised, 1);
pos = saveXLS(filename, 1, ["Average Noised Results - Neighbors sum"; "Average Noised Results - Wholw curve sum minus deconvolved sum";...
    "Noised Signals"; "Deconvolved Noised Signals"; "Noised Results"],...
    {meanNeighbors; meanWholeCurve; allNoisedSignals; allDeconvolvedNoisedSignals; allResultsNoisedNeighbors}, pos);
close(f);
 
function [neighborsResult, wholeCurveResult] = SNRTests(signs, deconvSigns, deconvNoises, noisedBool)
    neighborsResult = [];
    wholeCurveResult = [];
    switch noisedBool
        case 0
            for i = 1: 12
                result = 100-(sum(deconvSigns(i, 45:55))*100/signs(i, 50));
                neighborsResult = [neighborsResult, result];
            end
        case 1
            for i = 1: 12
                result = 100-(sum(deconvSigns(i, 45:55))*100/signs(i, 50));
                neighborsResult = [neighborsResult, result];
                decMinusNoise = sum(deconvSigns(i, :)) - sum(deconvNoises(i, :));
                result = 100-(decMinusNoise*100/signs(i, 50));
                wholeCurveResult = [wholeCurveResult, result];
            end
    end
    
end
 
function pos = saveXLS(filename, pageName, titles, data, initialPos)
    F = waitbar(0,'Please wait... Writing XLS');
    tic
    pos = initialPos;
    for i = 1: length(data)
        writematrix(titles(i,:), filename, 'Sheet', pageName, 'Range', 'B' + string(pos))
        pos = pos + 2;
        writematrix(data{i} , filename,'Sheet', pageName, 'Range', 'B' + string(pos))
        pos = pos + size(data{i}, 1) + 1;
        waitbar(i/length(data), F, 'Writing XLS... ('+string(i*100/length(data))+'%)');
    end
    toc
    close(F)
end
 
function plotResults(sign, kernel, dec)
    figure;
    subplot(1,2,1);
    plot(1:100, sign); hold on
    plot(kernel)
    legend("Signal Amplitude M = 3", "Signal Amplitude M = 4", "Signal Amplitude M = 5", "Signal Amplitude M = 6",...
        "Signal Amplitude M = 7", "Signal Amplitude M = 8", "Signal Amplitude M = 9", "Signal Amplitude M = 10",...
        "Signal Amplitude M = 11","Signal Amplitude M = 12","Signal Amplitude M = 13","Signal Amplitude M = 14","Kernel", 'FontSize', 13);
    title(["Noised Signals", "Amplitude SNR"], 'FontSize', 16)
    ylabel("Amplitude")
    xlabel("Space")
    grid on
    subplot(1,2,2);
    plot(1: 100, dec);
    legend("Deconvolution Amplitude M = 3", "Deconvolution Amplitude M = 4", "Deconvolution Amplitude M = 5", "Deconvolution Amplitude M = 6",...
        "Deconvolution Amplitude M = 7", "Deconvolution Amplitude M = 8", "Deconvolution Amplitude M = 9", "Deconvolution Amplitude M = 10",...
        "Deconvolution Amplitude M = 11", "Deconvolution Amplitude M = 12", "Deconvolution Amplitude M = 13",...
        "Deconvolution Amplitude M = 14", 'FontSize', 13);
    title(["Deconvolved Signals", "Amplitude SNR"], 'FontSize', 16)
    ylabel("Amplitude")
    xlabel("Space")
    grid on
end

function dif = diffusion1D(time, M, d, x, desv)
    left = M / (2 * sqrt(pi * d * time));
    expo = exp((- ((x-desv).^2))/(4 * d * time));
    dif = left * expo;
end