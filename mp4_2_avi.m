function mp4_2_avi(filename,path)
    %create objects to read and write the video
    readerObj = VideoReader(strcat(path,filename));
    writerObj = VideoWriter(strcat(path,filename,'.avi'),'Motion JPEG AVI');

    %open AVI file for writing
    open(writerObj);

    %read and write each frame
    for k = 1:readerObj.NumberOfFrames
       img = read(readerObj,k);
       writeVideo(writerObj,img);
    end
    close(writerObj);
end