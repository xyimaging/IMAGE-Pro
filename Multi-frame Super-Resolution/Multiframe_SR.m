function z_k = Multiframe_SR(image_frame,image_motion,factor,u_k,lambda,iter)
cell_im = num2cell(image_frame,[2,3]);
for i = 1:length(cell_im)
    cell_im{i} = squeeze(cell_im{i});
end

max_iter = iter;
norm_ = "norm2";

%laplacian
gamma = -1 * ones(3,3)/9;
gamma(2,2) = gamma(2,2)+1;
gamma_t = rot90(gamma,2);

% initial the f via upsampling the first frame
z_k = zeros(256, 256);
z_k(1:factor:end,1:factor:end) = cell_im{1};

G = zeros(256,256,length(cell_im));
for iter = 1:max_iter
    % calculate derivative of likelyhood
    for i = 1:length(cell_im)
        % D*S*Z
        DSZ = zeros(256,256);
        %image_Frame(1+x_(x_k):end,1+y_(y_k):end) = g_blur(1:256-x_(x_k),1:256-y_(y_k));
        DSZ(1:256+image_motion(i,1),1:256+image_motion(i,2)) ...
            = z_k(1-image_motion(i,1):256,1-image_motion(i,2):256);
        DSZ = DSZ(1:factor:end, 1:factor:end);
        % D*S*Z - g(i)
        DSZ_ = DSZ - cell_im{i};
        % St*Dt*(D*S*Z - g(i)), here we using nearest?
        Likely = zeros(256, 256);
        Likely(1:factor:end,1:factor:end) = DSZ_;
        Likely_ = zeros(256, 256);
        Likely_(1-image_motion(i,1):256,1-image_motion(i,2):256) ...
            = Likely(1:256+image_motion(i,1),1:256+image_motion(i,2));
        G(:,:,i) = Likely_;
    end
    % select norm1 or norm2
    switch (norm_)
        case "norm2"
            likelyhood = sum(G,3);
        case "norm1"
            likelyhood = median(G,3);
    end
    % the derivation of tikhonov regularition term
    priori_r = imfilter(z_k,gamma,'symmetric','same','conv');
    priori_r = lambda.*imfilter(priori_r,gamma_t,'symmetric','same','conv');
    %priori_r = 0;

    % define stepsize (step size is actually 2*u_k here)
    z_k = z_k - u_k.*(likelyhood + priori_r);

    % calculate the Lmap, use it as a judgement
    for kk = 1:length(cell_im)
        est = zeros(256,256);
        est(1:256+image_motion(i,1),1:256+image_motion(i,2)) ...
            = z_k(1-image_motion(i,1):256,1-image_motion(i,2):256);
        est = est(1:factor:end, 1:factor:end);
        norm_est(:,:,kk) = norm(cell_im{i}- est);
    end
    norm_est = sum(norm_est,3);
    Lmap = norm_est + lambda.*norm(imfilter(z_k,gamma,'symmetric','same','conv'));
    %Lmap = norm_est
end
end