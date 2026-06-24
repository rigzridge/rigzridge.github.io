
function createPhaseSpace(ampsX,ampsV,phaseX,phaseV,N=512,rot=0.0) {

    t = linspace(0,1.0,N);
    dt = 2*Math.PI*(t[1] - t[0]);
    Nharm = ampsX.length;
    x = new Float32Array(N);
    v = new Float32Array(N);

    for (let n=0; n<N; n++) {
        for (let i=1; i<Nharm; i++) {
            x[n] += 2*ampsX[i]*Math.cos(i*2*Math.PI*t[n] + phaseX[i]*Math.PI);
            v[n] += 2*ampsV[i]*Math.cos(i*2*Math.PI*t[n] + phaseV[i]*Math.PI);
        }
        // Handle DC
        x[n] += ampsX[0]*Math.cos(phaseX[0]*Math.PI);
        v[n] += ampsV[0]*Math.cos(phaseV[0]*Math.PI);
    }
    // t = np.append(t,t[-1]+dt)
    // x = np.append(x,x[0])
    // v = np.append(v,v[0])

    rot *= Math.PI/180;
    for (let n=0; n<N; ++n) {
        let dumx, dumv;
        dumx = Math.cos(rot) * x[n] - Math.sin(rot) * v[n];
        dumv = Math.sin(rot) * x[n] + Math.cos(rot) * v[n];
        x[n] = dumx;
        v[n] = dumv;
    }
    
    return {t,x,v};
}


function createWaveform(amps,phases,N=512) {

    t = linspace(0,1.0,N);
    dt = 2*Math.PI*(t[1] - t[0]);
    Nharm = amps.length;
    x = new Float32Array(N);

    for (let n=0; n<N; n++) {
        for (let i=1; i<Nharm; i++) {
            x[n] += 2*amps[i]*Math.cos(i*2*Math.PI*t[n] + phases[i]*Math.PI);
        }
        // Handle DC
        x[n] += amps[0]*Math.cos(phases[0]*Math.PI);
    }
    // t = np.append(t,t[-1]+dt)
    // x = np.append(x,x[0])
    // v = np.append(v,v[0])
    
    return {t,x};
}

function smoothPhaseSpace(x,v,Nharm=1,N=8,rot=0.0) {

    const fftX = DFT(x,Nharm+1);
    const fftV = DFT(v,Nharm+1);

    const newPS = createPhaseSpace(fftX.magnitudes,fftV.magnitudes,fftX.phases,fftV.phases,N=N,rot=rot);
    return newPS;
}



function XV2TX(x,v) {

    lim = x.length;
    const t = [0];
    const dt = [0];
    for (let i=1; i<=lim-2; i++) {
        // dt[i] = 6*(x[i+1] - x[i]) / (4*v[i+1] + v[i] + v[i-1]);
        dt[i] = 4*(x[i+1] - x[i]) / (v[i+1] + 4*v[i] - v[i-1]);
        // dt[i] = (x[i+1] - x[i]) / v[i];
        t[i] = t[i-1] + Math.abs(dt[i]);
    }

    return t;
}



// --- 5. FOURIER SYNTH ANALYSIS ENGINE ---
function DFT(data,numCoefficients) {
    const real = new Float32Array(numCoefficients);
    const imag = new Float32Array(numCoefficients);
    const magnitudes = new Float32Array(numCoefficients);
    const phases = new Float32Array(numCoefficients);

    const N = data.length;
    for (let k = 0; k < numCoefficients; k++) {
        let cosSum = 0;
        let sinSum = 0;
        for (let n = 0; n < N; n++) {
            const angle = (2 * Math.PI * k * n) / N;
            cosSum += data[n] * Math.cos(angle);
            sinSum += data[n] * Math.sin(angle);
        }
        real[k] = cosSum / N;
        imag[k] = -sinSum / N; 

        // Magnitude = sqrt(A² + B²)
        // This represents the true sound weight/volume of this specific harmonic pitch channel
        magnitudes[k] = Math.sqrt(real[k] * real[k] + imag[k] * imag[k]);
        phases[k] = Math.atan2(imag[k], real[k]) / Math.PI;
        // Convert angle to 0 to 2*PI range instead of -PI to PI
        // if (phases[k] < 0) {
        //     phases += 2 * Math.PI;
        // }
    }
    // console.log(phases)
    // return audioCtx.createPeriodicWave(real, imag, {disableNormalization: false});
    return {real, imag, magnitudes, phases} 
}

function find_left_x(x,dumx) {
    n = x.length;
    ind = 0;
    for (let i=0; i<n; i++) {
        if (x[i]<=dumx) ind = i;
    }
    return ind;
}

function linterp(x, y, xnew) {
    Nnew = xnew.length;
    N = x.length;
    ynew = [];
    for (let i=0; i<Nnew; i++) {
        dumx = xnew[i];
        ind = find_left_x(x,dumx);
        xi = x[ind];
        if (xi == dumx) {
            ynew[i] = y[ind];
        }
        else if (ind==N-1) {
            ynew[i] = y[ind];
        }
        else {
            ynew[i] = y[ind] + (dumx - xi) * ((y[ind+1] - y[ind]) / (x[ind+1] - xi))
        }
    }   
    return ynew;
}

function linspace(start, stop, num) {
    if (num <= 0) return [];
    if (num === 1) return [start];
    
    const arr = new Float32Array(num);
    const step = (stop - start) / (num - 1);
    
    for (let i = 0; i < num; i++) {
        arr[i] = start + (step * i);
    }
    return arr;
}

function dxdt(x,dt=1.0) {

    N = x.length;
    dx = new Float32Array(N);
    for (let i=0; i<N-1; ++i) {
        dx[i] = (x[i+1] - x[i])/dt;
    }
    dx[N-1] = (x[0] - x[N-1])/dt;

    return dx;
}

function resampleData(t,x,Nint) {

    newt = linspace(0,t[t.length-1],Nint);
    newx = linterp(t, x, newt);

    return {newt, newx};
}


