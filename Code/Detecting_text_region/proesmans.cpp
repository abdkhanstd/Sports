/* Optical flow calculation using the gradient-based method devised by Marc Proesmans.          */

/* This code was originally developed by Steven Mills, slightly modified by Ben Galvin,
 * and assembled in the present form by Giampiero Campa, with help from Brendan McCane.
 * The algorithm was first described in this journal paper:
   McCane, B., Novins, K., Crannitch, D., and Galvin, B. (2001) "On Benchmarking Optical Flow"
   Computer Vision and Image Understanding, 84(1), 126-143.
 * This specific code was also described and used in the following journal paper:
   Mammarella, M., Campa, G., Fravolini, M. L., and Napolitano, M. R., "Comparing Optical Flow
   Algorithms Using 6-DOF Motion of Real-World Rigid Objects"; IEEE Transaction on Systems,
   Man, and Cybernetics-Part C: Applications and Reviews, Vol 42, No. 6, Nov. 2012, 1752-1762   */

/* If you use this algorithm in any published work, please cite the above papers.               */

/* USAGE:
 * from the MATLAB command line, compile using the command:
   mex proesmans.cpp
 * then try it as follows:
   A=imread('blocks.1.gif');B=imread('blocks.2.gif');   % read images in A and B
   PF=zeros(size(A,1),size(A,2),2);PR=PF;               % allocate PF and PR
   iter=50;lambda=30;level=4;Est=0;                     % define parameters
   [F,R]=proesmans(A,B,iter,lambda,level,PF,PR,Est);    % call the proesmans function
   figure;imshow(A);figure;imshow(B);                   % display images A and B
   figure;imshow(F(:,:,1));figure;imshow(F(:,:,2));     % display forward flow along both dims  */

/* Explanation of input and oputput arguments (F,R,A,B,iter,lambda,level,PF,PR,Est):            */

/* A and B are either Grey-level or RGB MATLAB images, that is uint8 matrices with size 1 or 3
 * along the third dimension. F and R represent the forward and reverse optical flow, specifically
 * F(:,:,1) and F(:,:,2) are the forward flow velocities along the vertical (up to down)
 * and horizontal (left to right) axis of the image, calculated for each image point.	        */

/* The paramaters iter, lambda, and level are respectively the maximum number of iterations,
 * a regularization/smoothing parameter, and a multiscale factor. Specifically, a small lambda
 * (say =1), means we should trust the data and mantain the edges, so the resulting flow is
 * likely to be noisy. A larger lambda trusts the data less so it smooths the edges,
 * therefore resulting in a smoother flow. The effect is only noticeable near areas of high
 * image gradient, it shouldn't make much of a difference in relatively smooth areas.
 * Choosing a level factor of 2 will result in scaling the image by 0.5,
 * perform an optical flow calculation, then scale the result back up to use as the initial
 * estimate for the full blown optical flow estimation.											*/

/* ******************************************************************************************** */
/* Basic data structure and subfunction follow, actual MEX function code starting from line 732 */

/* basic MATLAB includes */
#include "mex.h"
#include <math.h>

/* includes from proesman.c */
/* #include "proesmans.h"   */
/* #include "my_pnm.h"      */
/* #include <assert.h>      */

/* defines from proesman.c  */
#define DEBUG (0)								/* turns debugging statements on/off */
#define ABS(X) ((X) > (0.0) ? (X) : -(X))		/* Needed as abs is defined only for integers! */
#define SQR(X) ((X) * (X))
#define MAX(A, B) ((A) > (B) ? (A) : (B))
#define MAXABS(A, B) (ABS(A) > ABS(B) ? (A) : (B))
#define COMBINE(A, B, C) (MAXABS(MAXABS(A, B), C))		  /* How to combine RGB gradients etc. */


/*  flow structures */

struct flow_struct{
    int maxx, maxy;
    float **u, **v;
};

typedef struct flow_struct flow;

struct twin_flows {
    flow forward, reverse;
};


/* picture structures */

typedef float my_pixval;

struct picture_struct {
    int width, height;
    my_pixval **r, **g, **b;
};

typedef struct picture_struct picture;


/* allocation routines */

float **alloc_float_space(int maxx, int maxy) {
    int x;
    float *grid;
    float **cols;
    
    grid = (float *) calloc(maxx*maxy, sizeof(float));
    cols = (float **) calloc(maxx, sizeof(float *));
    
    for(x = 0; x < maxx; x++)
        cols[x] = &grid[x*maxy];
    
    return cols;
} // alloc_float_space

void free_float_space(float **p) {
    free(p[0]);
    free(p);
} // free_float_space

flow alloc_flow(int maxx, int maxy) {
    flow F;
    int x, y;
    
    F.maxx = maxx;
    F.maxy = maxy;
    F.u = alloc_float_space(maxx, maxy);
    F.v = alloc_float_space(maxx, maxy);
    for (x = 0; x < maxx; x++)
        for (y = 0; y < maxy; y++) {
            F.u[x][y] = 0.0;
            F.v[x][y] = 0.0;
        }
    
    return F;
} // alloc_flow

void free_flow(flow F) {
    free_float_space(F.u);
    free_float_space(F.v);
} // free_flow


picture new_pic(int width, int height){
    int x, y;
    my_pixval *grid_r, *grid_g, *grid_b;
    picture P;
    
    grid_r = (my_pixval *) calloc(width * height, sizeof(my_pixval));
    grid_g = (my_pixval *) calloc(width * height, sizeof(my_pixval));
    grid_b = (my_pixval *) calloc(width * height, sizeof(my_pixval));
    P.r = (my_pixval **) calloc(width, sizeof(my_pixval *));
    P.g = (my_pixval **) calloc(width, sizeof(my_pixval *));
    P.b = (my_pixval **) calloc(width, sizeof(my_pixval *));
    
    for (x = 0; x < width; x++){
        P.r[x] = &grid_r[x*height];
        P.g[x] = &grid_g[x*height];
        P.b[x] = &grid_b[x*height];
    }
    
    for (x = 0; x < width; x++)
        for (y = 0; y < height; y++) {
            P.r[x][y] = 0.0;
            P.g[x][y] = 1.0;
            P.b[x][y] = 0.0;
        }
    
    P.height = height;
    P.width = width;
    
    return P;
}

void free_pic(picture P){
    free(P.r[0]);
    free(P.r);
    free(P.g[0]);
    free(P.g);
    free(P.b[0]);
    free(P.b);
}


/* a MATLAB image is an array with first dimension = height and second = width   */
/* remember indexing: y[i+j*n[0]] += (*up1[i+k*n[0]])*(*up2[k+j*n[1]]);          */
/* note that pic seem to be transposed respect to the MATLAB matrix structure    */

picture pictureOf(unsigned char *I, int h, int w, int d)
{
    picture pic;
    int y,x,k;
    
    k = (d > 2  ?  1 : 0);
    
    pic=new_pic(w,h);
    for(y=0;y<h;y++)
        for(x=0;x<w;x++) {
            pic.r[x][y]=(1/256.0)*I[x+w*y+0*h*w*k];
            pic.g[x][y]=(1/256.0)*I[x+w*y+1*h*w*k];
            pic.b[x][y]=(1/256.0)*I[x+w*y+2*h*w*k];
        }
    return pic;
}

/* array conversion routines */

float *array2Dto1D(float **in,float *out,unsigned int w,unsigned int h)
{
    unsigned int x,y;
    float *o=out;
    for(y=0;y<h;y++)
        for(x=0;x<w;x++)
            *(o++)=in[x][y];
    return out;
}

float **array1Dto2D(float *in,float **out,unsigned int w,unsigned int h)
{
    unsigned int x,y;
    float *i=in;
    for(y=0;y<h;y++)
        for(x=0;x<w;x++)
            out[x][y]=*(i++);
    return out;
}

/* transformation from 3d array to flow and viceversa */

void mat2flow(double *pmat, flow *pflow) {
    
    unsigned int x,y, h,w;
    
    /* assign flow dimensions */
    w = pflow->maxx;
    h = pflow->maxy;
    
    /* populate u and v */
    for (y=0; y<h; y++)
        for (x=0; x<w; x++) {
            pflow->u[x][y] = pmat[x+w*y+h*w*0];
            pflow->v[x][y] = pmat[x+w*y+h*w*1];
        }
}


void flow2mat(flow *pflow, double *pmat) {
    
    unsigned int x,y, h,w;
    
    /* rename dimensions */
    h=pflow->maxy; w=pflow->maxx;
    
    /* populate 3D matrix */
    for (y=0; y<h; y++)
        for (x=0; x<w; x++) {
            pmat[x+w*y+h*w*0] = pflow->u[x][y];
            pmat[x+w*y+h*w*1] = pflow->v[x][y];
        }
}


/* flow and picture scaling */
flow double_flow(flow F,flow& DF) {
    // Scale the flow up
    int x, y;
    
    for (x = 0; x < (F.maxx); x++)
        for (y = 0; y < (F.maxy); y++) {
            DF.u[2*x][2*y] = 2*F.u[x][y];
            DF.u[2*x][2*y+1] = 2*F.u[x][y];
            DF.u[2*x+1][2*y] = 2*F.u[x][y];
            DF.u[2*x+1][2*y+1] = 2*F.u[x][y];
            DF.v[2*x][2*y] = 2*F.v[x][y];
            DF.v[2*x][2*y+1] = 2*F.v[x][y];
            DF.v[2*x+1][2*y] = 2*F.v[x][y];
            DF.v[2*x+1][2*y+1] = 2*F.v[x][y];
        }
    
    return(DF);
}

picture half_pic(picture p) {
    // A half-scale version of the picture p
    int x, y, maxx, maxy;
    picture half;
    
    maxx = p.width / 2;
    maxy = p.height / 2;
    
    half = new_pic(maxx, maxy);
    
    for (x = 0; x < maxx; x++)
        for (y = 0; y < maxy; y++) {
            half.r[x][y] = (p.r[2*x][2*y] + p.r[2*x][2*y+1] +
                    p.r[2*x+1][2*y] + p.r[2*x+1][2*y+1]) / 4.0;
            half.g[x][y] = (p.g[2*x][2*y] + p.g[2*x][2*y+1] +
                    p.g[2*x+1][2*y] + p.g[2*x+1][2*y+1]) / 4.0;
            half.b[x][y] = (p.b[2*x][2*y] + p.b[2*x][2*y+1] +
                    p.b[2*x+1][2*y] + p.b[2*x+1][2*y+1]) / 4.0;
        }
    
    return(half);
} // half-size

flow half_flow(flow p) {
    // A half-scale version of the picture p
    int x, y, maxx, maxy;
    flow half;
    
    maxx = p.maxx / 2;
    maxy = p.maxy / 2;
    
    half = alloc_flow(maxx, maxy);
    
    for (x = 0; x < maxx; x++)
        for (y = 0; y < maxy; y++) {
            half.u[x][y] = 0.25*(p.u[2*x][2*y] + p.u[2*x][2*y+1] +
                    p.u[2*x+1][2*y] + p.u[2*x+1][2*y+1]);
            half.v[x][y] = 0.25*(p.v[2*x][2*y] + p.v[2*x][2*y+1] +
                    p.v[2*x+1][2*y] + p.v[2*x+1][2*y+1]);
        }
    
    return(half);
} // half-size


///////////////////////////
// Gradient calculations //
///////////////////////////

float **calc_Ex(picture P){
    // Estimate of the image gradient w.r.t. X
    // Sobel operators are used and smoothness is assumed at the edges
    int x, y, maxx, maxy;
    float **grad;
    float R, G, B;
    
    maxx = P.width;
    maxy = P.height;
    grad = alloc_float_space(maxx, maxy);
    for (x = 1; x < (maxx-1); x++)
        for (y = 1; y < (maxy-1); y++) {
            R = ((P.r[x+1][y-1] + 2*P.r[x+1][y] + P.r[x+1][y+1]) -
                    (P.r[x-1][y-1] + 2*P.r[x-1][y] + P.r[x-1][y+1]))/4.0;
            G = ((P.g[x+1][y-1] + 2*P.g[x+1][y] + P.g[x+1][y+1]) -
                    (P.g[x-1][y-1] + 2*P.g[x-1][y] + P.g[x-1][y+1]))/4.0;
            B = ((P.b[x+1][y-1] + 2*P.b[x+1][y] + P.b[x+1][y+1]) -
                    (P.b[x-1][y-1] + 2*P.b[x-1][y] + P.b[x-1][y+1]))/4.0;
            grad[x][y] = COMBINE(R, G, B);
        }
    grad[0][0] = grad[1][1];
    grad[maxx-1][0] = grad[maxx-2][1];
    grad[0][maxy-1] = grad[1][maxy-2];
    grad[maxx-1][maxy-1] = grad[maxx-2][maxy-2];
    
    for (x = 1; x < (maxx-1); x++) {
        grad[x][0] = grad[x][1];
        grad[x][maxy-1] = grad[x][maxy-2];
    }
    
    for (y = 1; y < (maxy-1); y++) {
        grad[0][y] = grad[1][y];
        grad[maxx-1][y] = grad[maxx-2][y];
    }
    
    return grad;
}

float **calc_Ey(picture P){
    // Estimate of the image gradient w.r.t. Y
    // Sobel operators are used and smoothness is assumed at the edges
    int x, y, maxx, maxy;
    float **grad;
    float R, G, B;
    
    maxx = P.width;
    maxy = P.height;
    grad = alloc_float_space(maxx, maxy);
    for (x = 1; x < (maxx-1); x++)
        for (y = 1; y < (maxy-1); y++) {
            R = ((P.r[x-1][y+1] + 2*P.r[x][y+1] + P.r[x+1][y+1]) -
                    (P.r[x-1][y-1] + 2*P.r[x][y-1] + P.r[x+1][y-1]))/4.0;
            G = ((P.g[x-1][y+1] + 2*P.g[x][y+1] + P.g[x+1][y+1]) -
                    (P.g[x-1][y-1] + 2*P.g[x][y-1] + P.g[x+1][y-1]))/4.0;
            B = ((P.b[x-1][y+1] + 2*P.b[x][y+1] + P.b[x+1][y+1]) -
                    (P.b[x-1][y-1] + 2*P.b[x][y-1] + P.b[x+1][y-1]))/4.0;
            grad[x][y] = COMBINE(R, G, B);
        }
    grad[0][0] = grad[1][1];
    grad[maxx-1][0] = grad[maxx-2][1];
    grad[0][maxy-1] = grad[1][maxy-2];
    grad[maxx-1][maxy-1] = grad[maxx-2][maxy-2];
    
    for (x = 1; x < (maxx-1); x++) {
        grad[x][0] = grad[x][1];
        grad[x][maxy-1] = grad[x][maxy-2];
    }
    
    for (y = 1; y < (maxy-1); y++) {
        grad[0][y] = grad[1][y];
        grad[maxx-1][y] = grad[maxx-2][y];
    }
    return grad;
}

float **calc_Et(picture P1, picture P2){
    // Estimate of the image gradient w.r.t. time between P1 and P2
    int x, y, maxx, maxy;
    float R, G, B;
    float **grad;
    
    maxx = P1.width;
    maxy = P1.height;
    grad = alloc_float_space(maxx, maxy);
    for (x = 0; x < maxx; x++)
        for (y = 0; y < maxy; y++) {
            R = P2.r[x][y] - P1.r[x][y];
            G = P2.g[x][y] - P1.g[x][y];
            B = P2.b[x][y] - P1.b[x][y];
            grad[x][y] = COMBINE(R, G, B);
        }
    
    return grad;
}

//////////////////////////////////////////////////
// General functions used later but not in main //
//////////////////////////////////////////////////

float interpolate(float **P, float x, float y) {
    // bilinear interpolation
    int base_x, base_y;
    float dx, dy, value;
    base_x = (int)floor(x);
    base_y = (int)floor(y);
    dx = x - base_x;
    dy = y - base_y;
    if ((dx == 0.0) && (dy == 0.0)) {
        value = P[base_x][base_y];
    } else if (dx == 0.0) {
        value = (1-dy)*P[base_x][base_y] + dy*P[base_x][base_y+1];
    } else if (dy == 0.0) {
        value = (1-dx)*P[base_x][base_y] + dx*P[base_x+1][base_y];
    } else {
        value = ((1-dx)*(1-dy)*P[base_x][base_y] +
                (1-dx)*(dy)*P[base_x][base_y+1] +
                (dx)*(1-dy)*P[base_x+1][base_y] +
                (dx)*(dy)*P[base_x+1][base_y+1]);
    }
    return value;
}


void fix_edges(flow *F) {
    // Set the flow at the edges to be equal to that of the nearest neighbour
    int x, y, maxx, maxy;
    
    maxx = F->maxx;
    maxy = F->maxy;
    // Patch up corners
    F->u[0][0] = F->u[1][1];
    F->v[0][0] = F->v[1][1];
    F->u[0][maxy-1] = F->u[1][maxy-2];
    F->v[0][maxy-1] = F->v[1][maxy-2];
    F->u[maxx-1][0] = F->u[maxx-2][1];
    F->v[maxx-1][0] = F->v[maxx-2][1];
    F->u[maxx-1][maxy-1] = F->u[maxx-2][maxy-2];
    F->v[maxx-1][maxy-1] = F->v[maxx-2][maxy-2];
    // Top and bottom edges
    for(x = 1; x < (F->maxx-1); x++){
        F->u[x][0] = F->u[x][1];
        F->v[x][0] = F->v[x][1];
        F->u[x][maxy-1] = F->u[x][maxy-2];
        F->v[x][maxy-1] = F->v[x][maxy-2];
    }
    // Left and right edges
    for(y = 1; y < (F->maxy-1); y++){
        F->u[0][y] = F->u[1][y];
        F->v[0][y] = F->v[1][y];
        F->u[maxx-1][y] = F->u[maxx-2][y];
        F->v[maxx-1][y] = F->v[maxx-2][y];
    }
} // fix_edges

float **compare(flow F1, flow F2) {
    // compares the flows F1 and F2, assuming them to be in opposite directions
    // The values of compare are in [0,1]
    // 1 means that the flow is perfectly consistent,
    // 0 means perfectly inconsistent, or that
    // the flow leads off image edges
    float **C;
    int x, y, maxx,maxy;
    float u_diff, v_diff;
    int pred_x, pred_y;
    float sum, K;
    int count;
    
    maxx = F1.maxx;
    maxy = F1.maxy;
    C = alloc_float_space(maxx, maxy);
    
    for (x = 0; x < maxx; x++)
        for (y = 0; y < maxy; y++) {
            pred_x = (int)(x + F1.u[x][y]);
            pred_y = (int)(y + F1.v[x][y]);
            if ((pred_x >= 0) && (pred_x <= (maxx-1)) &&
                    (pred_y >= 0) && (pred_y <= (maxy-1))) {
                u_diff = F1.u[x][y] + interpolate(F2.u, pred_x, pred_y);
                v_diff = F1.v[x][y] + interpolate(F2.v, pred_x, pred_y);
                C[x][y] = sqrt(SQR(u_diff) + SQR(v_diff));
            } else {
                // Flag this point as off the screen
                C[x][y] = -1.0;
            }
        }
    
    // Now C is in the range [0, infinity) where 0 indicates a perfect match
    // so run them thru a function to correct for this, putting them in [0,1]
    // Want zero to map to 1 and infinity to 0.
    sum = 0.0;
    count = 0;
    for (x = 0; x < maxx; x++)
        for (y = 0; y < maxy; y++)
            if (C[x][y] >= 0.0) {
                sum += C[x][y];
                count++;
            }
    
    if (count > 0) {
        K = 0.9 * sum / count;
        if (K > 0) {
            for (x = 0; x < maxx; x++)
                for (y = 0; y < maxy; y++) {
                    // The following are alternatives for g(|C|)
                    // C[x][y] = 1.0 is normal diffusion
                    if (C[x][y] >= 0.0) C[x][y] = 1.0 / (1.0 + SQR(C[x][y]/K));
//	  if (C[x][y] >= 0.0) C[x][y] = exp(-SQR(C[x][y]/K));
//	  C[x][y] = 1.0;
                }
        }
    }
    
    return C;
} // compare

void refine_flow(flow Old, flow *New, picture P1, picture P2,
        float **Ex, float **Ey, float lambda,
        float **consistency) {
    // The calculations used in each iteration
    float u_avg, v_avg, mult;
    int maxx, maxy;
    float pred_x, pred_y;
    int x, y;
    int k;
    float sum_of_weights, wgt;
    float R1, G1, B1, R2, G2, B2, c;
    
    int dx[8]={-1,0,1,1,1,0,-1,-1};
    int dy[8]={-1,-1,-1,0,1,1,1,0};
    
    maxx = Old.maxx;
    maxy = Old.maxy;
    
    for (x = 1; x < (maxx-1); x++)
        for (y = 1; y < (maxy-1); y++) {
            
            u_avg = v_avg = sum_of_weights = 0.0;
            for(k=0; k<8; k++)
                if ((c=consistency[x+dx[k]][y+dy[k]]) >= 0.0) {
                    wgt=1.0 + (k%2);
                    u_avg += wgt*Old.u[x+dx[k]][y+dy[k]]*c;
                    v_avg += wgt*Old.v[x+dx[k]][y+dy[k]]*c;
                    sum_of_weights += c*wgt;
                }
            
            if (sum_of_weights != 0.0) {
                u_avg /= sum_of_weights;
                v_avg /= sum_of_weights;
            } else {
                u_avg = Old.u[x][y];
                v_avg = Old.v[x][y];
            }
            
            pred_x = x + u_avg;
            pred_y = y + v_avg;
            if ((pred_x >= 0.0) && (pred_x <= (maxx-1)) &&
                    (pred_y >= 0.0) && (pred_y <= (maxy-1))) {
                R1 = P1.r[x][y] ;
                R2 = interpolate(P2.r, pred_x, pred_y);
                G1 = P1.g[x][y] ;
                G2 = interpolate(P2.g, pred_x, pred_y);
                B1 = P1.b[x][y] ;
                B2 = interpolate(P2.b, pred_x, pred_y);
                mult = (lambda * COMBINE((R2-R1), (G2-G1), (B2-B1))/
                        (1 + lambda * sqrt(SQR(Ex[x][y]) + SQR(Ey[x][y]))));
                New->u[x][y] = u_avg - Ex[x][y]*mult;
                New->v[x][y] = v_avg - Ey[x][y]*mult;
            } else {
                // flow moves off image edge so just go for smoothness
                New->u[x][y] = u_avg;
                New->v[x][y] = v_avg;
            }
        }
    
} // refine_flow;

#define sum_W(x, y, P, Q) \
(0.25*(1.0*P[x][y]*Q[x][y] +    \
        0.5*P[x+1][y]*Q[x+1][y] +      \
        0.5*P[x-1][y]*Q[x-1][y] +      \
        0.5*P[x][y+1]*Q[x][y+1] +      \
        0.5*P[x][y-1]*Q[x][y-1] +      \
        0.25*P[x+1][y+1]*Q[x+1][y+1] + \
        0.25*P[x+1][y-1]*Q[x+1][y-1] + \
        0.25*P[x-1][y+1]*Q[x-1][y+1] + \
        0.25*P[x-1][y-1]*Q[x-1][y-1]))
        
#define LIMIT 3.0
        
        
        flow first_guess(float **Ix, float **Iy, float **It, int maxx, int maxy,flow& Flow) {
    // Based on the presentation of Lucas & Kanade's method in
    // Bainbridge-Smith and Lane's paper
    float A, B, C, D, E, F;
    // Coefficients of the equations
    //  Au + Bv = C
    //  Du + Ev = F
    // Solutions to which are found from
    // (EA - BD)u = EC - BF
    // (DB - AE)v = DX - AF
    int x, y;
    
    for (x = 1; x < (maxx-1); x++)
        for (y = 1; y < (maxy-1); y++) {
            A = sum_W(x, y, Ix, Ix);
            B = sum_W(x, y, Ix, Iy);
            C = -sum_W(x, y, Ix, It);
            D = B;//sum_W(x, y, Iy, Ix);
            E = sum_W(x, y, Iy, Iy);
            F = -sum_W(x, y, Iy, It);
            if ((E*A - B*D) != 0.0) {
                Flow.u[x][y] = ((E*C - B*F) / (E*A - B*D));
                if (Flow.u[x][y] > LIMIT)    Flow.u[x][y] = LIMIT;
                if (Flow.u[x][y] < (-LIMIT)) Flow.u[x][y] = -LIMIT;
            } else {
                Flow.u[x][y] = 0.0;
            }
            if ((D*B - A*E) != 0.0) {
                Flow.v[x][y] = ((D*C - A*F) / (D*B - A*E));
                if (Flow.v[x][y] > LIMIT)    Flow.v[x][y] =  LIMIT;
                if (Flow.v[x][y] < (-LIMIT)) Flow.v[x][y] = -LIMIT;
            } else {
                Flow.v[x][y] = 0.0;
            }
        }
    fix_edges(&Flow);
    
    return(Flow);
} // first_guess


/////////////////////////////////////////
// Code for the functions used by main //
/////////////////////////////////////////

struct twin_flows  calculate_flow(picture P1, picture P2,
        int max_i, float lambda, int level,
        twin_flows& prev,int UseEstimate) {
    
    float **Ex1, **Ey1, **Ex2, **Ey2, **Et1, **Et2;
    float **forward_consistency, **reverse_consistency;
    int i;
    picture half1, half2;
    struct twin_flows twoflows,halff,next,temp;
    
    next.forward = alloc_flow(P1.width, P1.height);
    next.reverse = alloc_flow(P1.width, P1.height);
    Ex1 = calc_Ex(P1);
    Ey1 = calc_Ey(P1);
    Ex2 = calc_Ex(P2);
    Ey2 = calc_Ey(P2);
    Et1 = calc_Et(P1, P2);
    Et2 = calc_Et(P2, P1);
    
    if (level == 0) {
        if (!UseEstimate) {
            first_guess(Ex1, Ey1, Et1, P1.width, P1.height,prev.forward);
            first_guess(Ex2, Ey2, Et2, P2.width, P2.height,prev.reverse);
        }
    } else {
        half1 = half_pic(P1);
        half2 = half_pic(P2);
        if (UseEstimate) {
            halff.forward = half_flow(prev.forward);
            halff.reverse = half_flow(prev.reverse);
        } else {
            halff.forward=alloc_flow(prev.forward.maxx/2,prev.forward.maxy/2);
            halff.reverse=alloc_flow(prev.reverse.maxx/2,prev.reverse.maxy/2);
        }
        calculate_flow(half1, half2, max_i, lambda, (level-1),halff,1);
        double_flow(halff.forward, prev.forward);
        double_flow(halff.reverse, prev.reverse);
        free_flow(halff.forward);
        free_flow(halff.reverse);
        free_pic(half1); 
        free_pic(half2); 
    }
    
    for (i = 1; i <= max_i; i++) {
        if DEBUG fprintf(stderr, "* Level %d - Iteration %3d of %d\r",
                level, i, max_i);
        
        forward_consistency = compare(prev.forward, prev.reverse);
        refine_flow(prev.forward, &(next.forward), P1, P2, Ex1, Ey1, lambda, forward_consistency);
        fix_edges(&(next.forward));
        reverse_consistency = compare(prev.reverse, prev.forward);
        
        refine_flow(prev.reverse, &(next.reverse), P2, P1, Ex2, Ey2, lambda, reverse_consistency);
        fix_edges(&(next.reverse));
        free_float_space(forward_consistency);
        free_float_space(reverse_consistency);
        
        temp = next;
        next = prev;
        prev = temp;
    }
    if DEBUG fprintf(stderr, "\n");
    free_float_space(Ex1);
    free_float_space(Ey1);
    free_float_space(Ex2);
    free_float_space(Ey2);
    free_flow(next.forward);
    free_flow(next.reverse);
    free_float_space(Et1); 
    free_float_space(Et2); 

    return(prev);
} // twin_flows



/* *********************** ACTUAL MEX FUNCTION ************************************************ */

void mexFunction( int nlhs, mxArray *plhs[],
        int nrhs, const mxArray *prhs[])
        
{
    /* define variables */
    unsigned char *I1,*I2;
    double lambda, *frw, *rev, *prefrw, *prerev;
    unsigned int m,n,k,i,j, nd, max_i,level,UseEstimate, *size;
    
    struct twin_flows twoflows;
    picture frame1,frame2, pic;
    flow optical_flow;
    
    /* Check for proper number of arguments */
    if (nrhs > 8) {
        mexErrMsgTxt("Eight input arguments required.");
    } else if (nlhs > 2) {
        mexErrMsgTxt("Too many output arguments.");
    }
    
    /* deal with INPUT parameters ************************************************************* */
    
    /* prevent you from passing a sparse matrix, use mxIsDouble(prhs[0]) if it has to be double */
    if ( mxIsSparse(prhs[0]) || mxGetClassID(prhs[0])!= mxUINT8_CLASS)
        mexErrMsgTxt("usage: [frw,rev]=proesman(I1,I2,max_i,lambda,level,prefrw,prerev,UseEstimate); \n I1 must be uint8");
    
    /* prevent you from passing a sparse matrix, use mxIsDouble(prhs[1]) if it has to be double */
    if ( mxIsSparse(prhs[1]) || mxGetClassID(prhs[1])!= mxUINT8_CLASS)
        mexErrMsgTxt("usage: [frw,rev]=proesman(I1,I2,max_i,lambda,level,prefrw,prerev,UseEstimate); \n I2 must be uint8");
    
    /* check the dimensions of I1 & I2 */
    if ( mxGetM(prhs[0]) != mxGetM(prhs[1]) || 	mxGetN(prhs[0]) != mxGetN(prhs[1])) {
        mexErrMsgTxt("I1 & I2 must have same dimensions");
    }
    
    /* Assign pointers to the input parameters*/
    I1 = (unsigned char *) mxGetPr(prhs[0]);
    I2 = (unsigned char *) mxGetPr(prhs[1]);
    max_i = (unsigned int) *(mxGetPr(prhs[2]));
    lambda = (double) *(mxGetPr(prhs[3]));
    level = (unsigned int) *(mxGetPr(prhs[4]));
    prefrw = mxGetPr(prhs[5]);
    prerev = mxGetPr(prhs[6]);
    UseEstimate = (unsigned int) *(mxGetPr(prhs[7]));
    
    /* get I1 dimensions */
    nd = mxGetNumberOfDimensions(prhs[0]);
    size = (unsigned int*) mxGetDimensions(prhs[0]);
    
    /* assign I1 dimensions */
    m=size[0]; n=size[1];
    if ( nd > 2 ) k=size[2]; else k=1;
    
    /* copy frames from input MATLAB arrays */
    frame1=pictureOf(I1,n,m,k);
    frame2=pictureOf(I2,n,m,k);
    
    /* double check pic matrix structure */
    //printf("pic.g[3-1][4-1]=%f \n",256*pic.g[3-1][4-1]);
    
    /* get and check frw dimensions */
    nd = mxGetNumberOfDimensions(prhs[5]);
    size = (unsigned int*) mxGetDimensions(prhs[5]);
    if ( nd!=3 || size[2]<2 )
        mexErrMsgTxt("usage: [frw,rev]=proesman(I1,I2,max_i,lambda,level,prefrw,prerev,UseEstimate); \n prefrw 3rd dimension must be at least 2");
    
    /* allocate flow structure */
    twoflows.forward=alloc_flow(size[0],size[1]); /* warning: potential transposition problem */
    
    /* get and check rev dimensions */
    nd = mxGetNumberOfDimensions(prhs[6]);
    size = (unsigned int*) mxGetDimensions(prhs[6]);
    if ( nd!=3 || size[2]<2 )
        mexErrMsgTxt("usage: [frw,rev]=proesman(I1,I2,max_i,lambda,level,prefrw,prerev,UseEstimate); \n prerev 3rd dimension must be at least 2");
    
    /* allocate reverse flow structure */
    twoflows.reverse=alloc_flow(size[0],size[1]); /* warning: potential transposition problem */
    
    /* populate both flow structures */
    if (UseEstimate) {
        mat2flow(prefrw,&twoflows.forward);
        mat2flow(prerev,&twoflows.reverse);
    }
    
    /* double check flow structure */
    //printf("twoflows.forward.v[1-1][2-1]=%f \n",twoflows.forward.v[1-1][2-1]);
    
    
    /* deal with OUTPUT parameters ************************************************************ */
    
    /* Create a matrix for the output parameters */
    plhs[0] = mxCreateNumericArray(3, mxGetDimensions(prhs[5]), mxDOUBLE_CLASS, mxREAL);
    plhs[1] = mxCreateNumericArray(3, mxGetDimensions(prhs[6]), mxDOUBLE_CLASS, mxREAL);
    
    /* Assign pointers to the output parameters */
    frw = mxGetPr(plhs[0]);
    rev = mxGetPr(plhs[1]);
    
    /* do the actual computations ************************************************************* */
    calculate_flow(frame1, frame2, max_i, lambda, level, twoflows, UseEstimate);
    
    /* copy flows to output MATLAB arrays */
    flow2mat(&twoflows.forward,frw);
    flow2mat(&twoflows.reverse,rev);
    
    /* deallocate stuff */
    free_pic(frame1);
    free_pic(frame2);
    free_flow(twoflows.forward);
    free_flow(twoflows.reverse);
    
    return;
    
}

/* Copyright 2013 The MathWorks, Inc.                                                           */