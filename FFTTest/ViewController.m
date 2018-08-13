//
//  ViewController.m
//  FFTTest
//
//  Created by wudongyang on 2018/8/13.
//  Copyright © 2018年 吴冬炀. All rights reserved.
//

#import "ViewController.h"
#import <Accelerate/Accelerate.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    int N = 8;//must pow2
    int Nover2 = N/2; //2
    int log2N = log2(N); // 2
    float *datas = calloc(N, sizeof(float));
    
    datas[0] = 0;
    datas[1] = INT16_MAX;
    datas[2] = 0;
    datas[3] = -INT16_MAX;
    datas[4] = 0;
    datas[5] = INT16_MAX;
    datas[6] = 0;
    datas[7] = -INT16_MAX;
    
//    for (int i = 0; i < N; i ++) {
//        float f = datas[i];
//        NSLog(@"%f", f);
//    }
    
    DSPSplitComplex splitComplex;
    splitComplex.realp = calloc(Nover2, sizeof(float));
    splitComplex.imagp = calloc(Nover2, sizeof(float));
    FFTSetup setup = vDSP_create_fftsetup(log2N, FFT_RADIX2);
    
    float *outDatas = calloc(Nover2, sizeof(float));
    
    vDSP_ctoz((DSPComplex *) datas, 2, &splitComplex, 1, Nover2);
    vDSP_fft_zrip(setup, &splitComplex, 1, log2N, kFFTDirection_Forward);
    
    float Mul = 1.f/Nover2;//除去能量密度
    vDSP_vsmul(splitComplex.realp, 1, &Mul, splitComplex.realp, 1, Nover2);
    vDSP_vsmul(splitComplex.imagp, 1, &Mul, splitComplex.imagp, 1, Nover2);
    
    vDSP_zvmags(&splitComplex, 1, outDatas, 1, Nover2);//幅值的平方a^2
    
    float k0DB = 1;
    vDSP_vsadd(outDatas, 1, &k0DB, outDatas, 1, Nover2); //log(1)为0
    Float32 one = 1;
    vDSP_vdbcon(outDatas, 1, &one, outDatas, 1, Nover2, 0);//分贝： 10 * log10(a^2)  = 20 * log10(a)
    
    for (int i = 0; i < Nover2; i ++) {
        float f = outDatas[i];
        NSLog(@"magnitudes: %f", f);
    }
    
//    for (int i = 0; i < Nover2; i ++) {
//        float f = splitComplex.realp[i];
//        NSLog(@"real: %f", f);
//    }
//    for (int i = 0; i < Nover2; i ++) {
//        float f = splitComplex.imagp[i];
//        NSLog(@"imag: %f", f);
//    }
    
    
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
