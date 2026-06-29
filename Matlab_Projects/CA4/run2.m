%2.3
X = diabetes_training(:, trainedModel.RequiredVariables);

yTrue = table2array(diabetes_training(:, end));

yPred = trainedModel.predictFcn(X);

acc = mean(yPred == yTrue);

fprintf('Training accuracy = %.2f%%\n', 100*acc);

%2.4

Xval = diabetes_validation(:, trainedModel.RequiredVariables);

yTrue_val = table2array(diabetes_validation(:, end));

yPred_val = trainedModel.predictFcn(Xval);

acc_val = mean(yPred_val == yTrue_val);

fprintf('Validation/Test accuracy = %.2f%%\n', 100*acc_val);
