function res = measureCDnet(BW, GT)

GT = GT(:,:,1);
BW = BW(:,:,1);

BW = 255*(BW > 0.5);

imGT = GT;
imBinary = BW;

TP = sum(sum(imGT==255&imBinary==255));		% True Positive 
TN = sum(sum((imGT<=50)&imBinary==0));		% True Negative
FP = sum(sum((imGT<=50)&imBinary==255));	% False Positive
FN = sum(sum(imGT==255&imBinary==0));		% False Negative

recall = TP / (TP + FN + eps);
specficity = TN / (TN + FP + eps);
FPR = FP / (FP + TN + eps);
FNR = FN / (TP + FN + eps);
PBC = 100.0 * (FN + FP) / (TP + FP + FN + TN + eps);
precision = TP / (TP + FP + eps);
FMeasure = 2.0 * (recall * precision) / (recall + precision + eps);

S = TP / (TP + FN + FP + eps);
accuracy = (TP + TN) / (TP + FP + FN + TN + eps);
fmeasure = FMeasure;


res = [S FPR FNR precision recall accuracy fmeasure];
