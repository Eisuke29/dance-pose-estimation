%%
tic
inputvideo = VideoReader('input.mp4');% ビデオ読み込み

outputvideo = VideoWriter('output_dance_2.mp4','MPEG-4');% 出力ビデオ
outputvideo.FrameRate = inputvideo.FrameRate;%% フレームレートを合わせる
open(outputvideo);% 書き込み宣言

person_detect = yolov4ObjectDetector("csp-darknet53-coco");% 人物検出
keypoint_detect = hrnetObjectKeypointDetector("human-full-body-w32");% キーポイント検出

%%
while hasFrame(inputvideo)% 入力動画を最後まで繰り返す
    frame = readFrame(inputvideo);% フレームを一枚ずつ処理する
    %% コントラストの調整
    frame_hsv = rgb2hsv(frame);% HSVに変換
    frame_hsv(:,:,3) = min(frame_hsv(:,:,3) * 1.2, 1.0); % 明度を1.2倍（1.0を超えないようにmin）
    frame = hsv2rgb(frame_hsv);% RGBに戻す
    %% 人物の検出
    % [検出物体の位置と大きさ, 検出の信頼度, 検出物体のクラス名]
    [bboxes, scores, labels] = detect(person_detect, frame, threshold=0.4);
    personIdx = labels == "person";% labelがpersonかどうかの真偽値の配列
    personBoxes = bboxes(personIdx, :);% trueの行のみをbboxesから取得

    %% キーポイント検出
    if ~isempty(personBoxes)% personBoxesが空でなければ
        % 各関節の座標の取得
        [keypoints, ~, ~] = detect(keypoint_detect, frame, personBoxes);

        % 骨格の描画
        frame = insertObjectKeypoints(frame, keypoints, ...
                KeypointColor = "yellow", ...
                KeypointSize = 6, ...
                ConnectionColor="blue", ... 
                Connections = keypoint_detect.KeypointConnections);
    end
    % 動画に描き込み
    frame = uint8(frame * 255);% unit8に戻す
    writeVideo(outputvideo, frame);
end
close(outputvideo);% 動画ファイルを閉じて保存を確定
disp('完了');% 完了通知
toc