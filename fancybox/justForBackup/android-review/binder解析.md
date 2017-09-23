### Binder 解析
首先从一个例子开始
服务端代码：
```java
public class WeatherService extends Service{

    IWeatherInterface.Stub stub = new IWeatherInterface.Stub(){
        @Override
        public String getWeatherInfo(long timeMilli) throws RemoteException {
            return "五一劳动节，用劳动者的体温定义城市的温度。";
        }
    };

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return stub;
    }
}
```
IWeatherInterface的aidl文件定义如下：
```java
// IWeatherInterface.aidl
package binder.demo.kj.com.binderdemo;

// Declare any non-default types here with import statements

interface IWeatherInterface {
    String getWeatherInfo(long timeMilli);
}
```
此aidl文件生成了了个类IWeatherInterface.java
```java
/*
 * This file is auto-generated.  DO NOT MODIFY.
 * Original file: /home/caokeji/demo/google-example/android-architecture-todo-mvp/StartWeather/app/src/main/aidl/binder/demo/kj/com/binderdemo/IWeatherInterface.aidl
 */
package binder.demo.kj.com.binderdemo;
// Declare any non-default types here with import statements

public interface IWeatherInterface extends android.os.IInterface {
    /**
     * Local-side IPC implementation stub class.
     */
    public static abstract class Stub extends android.os.Binder implements binder.demo.kj.com.binderdemo.IWeatherInterface {
        private static final java.lang.String DESCRIPTOR = "binder.demo.kj.com.binderdemo.IWeatherInterface";

        /**
         * Construct the stub at attach it to the interface.
         */
        public Stub() {
            this.attachInterface(this, DESCRIPTOR);
        }

        /**
         * Cast an IBinder object into an binder.demo.kj.com.binderdemo.IWeatherInterface interface,
         * generating a proxy if needed.
         */
        public static binder.demo.kj.com.binderdemo.IWeatherInterface asInterface(android.os.IBinder obj) {
            if ((obj == null)) {
                return null;
            }
            android.os.IInterface iin = obj.queryLocalInterface(DESCRIPTOR);
            if (((iin != null) && (iin instanceof binder.demo.kj.com.binderdemo.IWeatherInterface))) {
                return ((binder.demo.kj.com.binderdemo.IWeatherInterface) iin);
            }
            return new binder.demo.kj.com.binderdemo.IWeatherInterface.Stub.Proxy(obj);
        }

        @Override
        public android.os.IBinder asBinder() {
            return this;
        }

        @Override
        public boolean onTransact(int code, android.os.Parcel data, android.os.Parcel reply, int flags) throws android.os.RemoteException {
            switch (code) {
                case INTERFACE_TRANSACTION: {
                    reply.writeString(DESCRIPTOR);
                    return true;
                }
                case TRANSACTION_getWeatherInfo: {
                    data.enforceInterface(DESCRIPTOR);
                    long _arg0;
                    _arg0 = data.readLong();
                    java.lang.String _result = this.getWeatherInfo(_arg0);
                    reply.writeNoException();
                    reply.writeString(_result);
                    return true;
                }
            }
            return super.onTransact(code, data, reply, flags);
        }

        private static class Proxy implements binder.demo.kj.com.binderdemo.IWeatherInterface {
            private android.os.IBinder mRemote;

            Proxy(android.os.IBinder remote) {
                mRemote = remote;
            }

            @Override
            public android.os.IBinder asBinder() {
                return mRemote;
            }

            public java.lang.String getInterfaceDescriptor() {
                return DESCRIPTOR;
            }

            @Override
            public java.lang.String getWeatherInfo(long timeMilli) throws android.os.RemoteException {
                android.os.Parcel _data = android.os.Parcel.obtain();
                android.os.Parcel _reply = android.os.Parcel.obtain();
                java.lang.String _result;
                try {
                    _data.writeInterfaceToken(DESCRIPTOR);
                    _data.writeLong(timeMilli);
                    mRemote.transact(Stub.TRANSACTION_getWeatherInfo, _data, _reply, 0);
                    _reply.readException();
                    _result = _reply.readString();
                } finally {
                    _reply.recycle();
                    _data.recycle();
                }
                return _result;
            }
        }

        static final int TRANSACTION_getWeatherInfo = (android.os.IBinder.FIRST_CALL_TRANSACTION + 0);
    }

    public java.lang.String getWeatherInfo(long timeMilli) throws android.os.RemoteException;
}

```
这个类里面包含了两个类，类关系图为<br>
<img src="http://o6lxzg30h.bkt.clouddn.com/binder2.jpeg" width="700"/>

其中 Stub是服务端使用的，Proxy是客户端使用的

另一个程序中，调用此服务的客户端通过下面的方法收到服务段返回的Binder
```java
Intent intent = new Intent();
      intent.setComponent(new ComponentName("binder.demo.kj.com.binderdemo","binder.demo.kj.com.binderdemo.WeatherService"));
      bindService(intent, new ServiceConnection() {
          @Override
          public void onServiceConnected(ComponentName name, IBinder service) {
              iWeatherInterface = IWeatherInterface.Stub.asInterface(service);
              String weatherInfo = iWeatherInterface.getWeatherInfo(System.currentTimeMillis())
          }

          @Override
          public void onServiceDisconnected(ComponentName name) {

          }
      },BIND_AUTO_CREATE);
```
返回的此IBinder其实是一个<font color=#008B8B>BinderProxy</font>,那BinderProxy又是什么呢，BinderProxy实在android.os.Binder.java文件中定义的
```java
final class BinderProxy implements IBinder {
    public native boolean pingBinder();
    public native boolean isBinderAlive();

    public IInterface queryLocalInterface(String descriptor) {
        return null;
    }

    public boolean transact(int code, Parcel data, Parcel reply, int flags) throws RemoteException {
        Binder.checkParcel(this, code, data, "Unreasonably large binder buffer");
        return transactNative(code, data, reply, flags);
    }

    public native String getInterfaceDescriptor() throws RemoteException;
    public native boolean transactNative(int code, Parcel data, Parcel reply,
            int flags) throws RemoteException;
    public native void linkToDeath(DeathRecipient recipient, int flags)
            throws RemoteException;
    public native boolean unlinkToDeath(DeathRecipient recipient, int flags);

    public void dump(FileDescriptor fd, String[] args) throws RemoteException {
        Parcel data = Parcel.obtain();
        Parcel reply = Parcel.obtain();
        data.writeFileDescriptor(fd);
        data.writeStringArray(args);
        try {
            transact(DUMP_TRANSACTION, data, reply, 0);
            reply.readException();
        } finally {
            data.recycle();
            reply.recycle();
        }
    }

    public void dumpAsync(FileDescriptor fd, String[] args) throws RemoteException {
        Parcel data = Parcel.obtain();
        Parcel reply = Parcel.obtain();
        data.writeFileDescriptor(fd);
        data.writeStringArray(args);
        try {
            transact(DUMP_TRANSACTION, data, reply, FLAG_ONEWAY);
        } finally {
            data.recycle();
            reply.recycle();
        }
    }

    BinderProxy() {
        mSelf = new WeakReference(this);
    }

    @Override
    protected void finalize() throws Throwable {
        try {
            destroy();
        } finally {
            super.finalize();
        }
    }

    private native final void destroy();

    private static final void sendDeathNotice(DeathRecipient recipient) {
        if (false) Log.v("JavaBinder", "sendDeathNotice to " + recipient);
        try {
            recipient.binderDied();
        }
        catch (RuntimeException exc) {
            Log.w("BinderNative", "Uncaught exception from death notification",
                    exc);
        }
    }

    final private WeakReference mSelf;
    private long mObject;
    private long mOrgue;
}
```
类的继承关系为<br>
<img src="http://o6lxzg30h.bkt.clouddn.com/binder3.jpeg" width="300"/>
上面的这行代码<font color=#008B8B>getWeatherInfo</font>是调用Proxy的方法

```java
String weatherInfo = iWeatherInterface.getWeatherInfo(System.currentTimeMillis());
```
IWeatherInterface里面的Proxy类的getWeatherInfo方法
```java
@Override
public java.lang.String getWeatherInfo(long timeMilli) throws android.os.RemoteException {
    android.os.Parcel _data = android.os.Parcel.obtain();
    android.os.Parcel _reply = android.os.Parcel.obtain();
    java.lang.String _result;
    try {
        _data.writeInterfaceToken(DESCRIPTOR);
        _data.writeLong(timeMilli);
        mRemote.transact(Stub.TRANSACTION_getWeatherInfo, _data, _reply, 0);
        _reply.readException();
        _result = _reply.readString();
    } finally {
        _reply.recycle();
        _data.recycle();
    }
    return _result;
}
```
此方法里的mRemote就是上面的BinderProxy,它的transact方法如下,内部调用了本地方法transactNative(code, data, reply, flags)
```java
public boolean transact(int code, Parcel data, Parcel reply, int flags) throws RemoteException {
        Binder.checkParcel(this, code, data, "Unreasonably large binder buffer");
        return transactNative(code, data, reply, flags);
    }
```
jni调用方法
```java
static const JNINativeMethod gBinderProxyMethods[] = {
     /* name, signature, funcPtr */
    {"pingBinder",          "()Z", (void*)android_os_BinderProxy_pingBinder},
    {"isBinderAlive",       "()Z", (void*)android_os_BinderProxy_isBinderAlive},
    {"getInterfaceDescriptor", "()Ljava/lang/String;", (void*)android_os_BinderProxy_getInterfaceDescriptor},
    {"transactNative",      "(ILandroid/os/Parcel;Landroid/os/Parcel;I)Z", (void*)android_os_BinderProxy_transact},
    {"linkToDeath",         "(Landroid/os/IBinder$DeathRecipient;I)V", (void*)android_os_BinderProxy_linkToDeath},
    {"unlinkToDeath",       "(Landroid/os/IBinder$DeathRecipient;I)Z", (void*)android_os_BinderProxy_unlinkToDeath},
    {"destroy",             "()V", (void*)android_os_BinderProxy_destroy},
};
//从上面声明中 transactNative对应的是 android_os_BinderProxy_transact

static jboolean android_os_BinderProxy_transact(JNIEnv* env, jobject obj,
        jint code, jobject dataObj, jobject replyObj, jint flags) // throws RemoteException
{
    if (dataObj == NULL) {
        jniThrowNullPointerException(env, NULL);
        return JNI_FALSE;
    }

    Parcel* data = parcelForJavaObject(env, dataObj);
    if (data == NULL) {
        return JNI_FALSE;
    }
    Parcel* reply = parcelForJavaObject(env, replyObj);
    if (reply == NULL && replyObj != NULL) {
        return JNI_FALSE;
    }

    //此target为BpBinder类型对象，gBinderProxyOffsets.mObject 为Java层的ProxyBinder中的mObject变量对应的偏移值，通过此方法可获取Java层mObject的值
    IBinder* target = (IBinder*)
        env->GetLongField(obj, gBinderProxyOffsets.mObject);
    if (target == NULL) {
        jniThrowException(env, "java/lang/IllegalStateException", "Binder has been finalized!");
        return JNI_FALSE;
    }

    ALOGV("Java code calling transact on %p in Java object %p with code %" PRId32 "\n",
            target, obj, code);


    bool time_binder_calls;
    int64_t start_millis;
    if (kEnableBinderSample) {
        // Only log the binder call duration for things on the Java-level main thread.
        // But if we don't
        time_binder_calls = should_time_binder_calls();

        if (time_binder_calls) {
            start_millis = uptimeMillis();
        }
    }

    //调用BpBinder的transact方法
    //printf("Transact from Java code to %p sending: ", target); data->print();
    status_t err = target->transact(code, *data, reply, flags);
    //if (reply) printf("Transact from Java code to %p received: ", target); reply->print();

    if (kEnableBinderSample) {
        if (time_binder_calls) {
            conditionally_log_binder_call(start_millis, target, code);
        }
    }

    if (err == NO_ERROR) {
        return JNI_TRUE;
    } else if (err == UNKNOWN_TRANSACTION) {
        return JNI_FALSE;
    }

    signalExceptionForError(env, obj, err, true /*canThrowRemoteException*/, data->dataSize());
    return JNI_FALSE;
}
```
BpBinder的transact方法如下,其实就是向驱动发送请求指令，binder驱动将指令跨进程传递到服务端Binder，也就是真正的Binder实体，BpBinder所持有的只是一个Binder引用
```java
status_t BpBinder::transact(
    uint32_t code, const Parcel& data, Parcel* reply, uint32_t flags)
{
    // Once a binder has died, it will never come back to life.
    if (mAlive) {
        status_t status = IPCThreadState::self()->transact(
            mHandle, code, data, reply, flags);
        if (status == DEAD_OBJECT) mAlive = 0;
        return status;
    }

    return DEAD_OBJECT;
}
```
指令发送后，服务端是如何收到的呢，其实服务端是有一个线程阻塞着的等待接收到新任务后就会被唤醒，这和网络请求很类似，网络请求服务端也是一直阻塞这等待这有客户端来连接请求，在IPCThreadState.cpp中，有任务后getAndExecuteCommand()中的talkWithDriver()方法从 ioctl(mProcess->mDriverFD, BINDER_WRITE_READ, &bwr)中返回，没有任务时此法方法请求会被binder驱动挂起，有任务后才会被重新唤醒。唤醒后通过此方法 status_t IPCThreadState::executeCommand(int32_t cmd) 来解析执行客户端传来的指令,我们只看里面的BR_TRANSACTION的代码片段
```java
case BR_TRANSACTION:
       {
           binder_transaction_data tr;
           result = mIn.read(&tr, sizeof(tr));
           ALOG_ASSERT(result == NO_ERROR,
               "Not enough command data for brTRANSACTION");
           if (result != NO_ERROR) break;

           Parcel buffer;
           buffer.ipcSetDataReference(
               reinterpret_cast<const uint8_t*>(tr.data.ptr.buffer),
               tr.data_size,
               reinterpret_cast<const binder_size_t*>(tr.data.ptr.offsets),
               tr.offsets_size/sizeof(binder_size_t), freeBuffer, this);

           const pid_t origPid = mCallingPid;
           const uid_t origUid = mCallingUid;
           const int32_t origStrictModePolicy = mStrictModePolicy;
           const int32_t origTransactionBinderFlags = mLastTransactionBinderFlags;

           mCallingPid = tr.sender_pid;
           mCallingUid = tr.sender_euid;
           mLastTransactionBinderFlags = tr.flags;

           int curPrio = getpriority(PRIO_PROCESS, mMyThreadId);
           if (gDisableBackgroundScheduling) {
               if (curPrio > ANDROID_PRIORITY_NORMAL) {
                   // We have inherited a reduced priority from the caller, but do not
                   // want to run in that state in this process.  The driver set our
                   // priority already (though not our scheduling class), so bounce
                   // it back to the default before invoking the transaction.
                   setpriority(PRIO_PROCESS, mMyThreadId, ANDROID_PRIORITY_NORMAL);
               }
           } else {
               if (curPrio >= ANDROID_PRIORITY_BACKGROUND) {
                   // We want to use the inherited priority from the caller.
                   // Ensure this thread is in the background scheduling class,
                   // since the driver won't modify scheduling classes for us.
                   // The scheduling group is reset to default by the caller
                   // once this method returns after the transaction is complete.
                   set_sched_policy(mMyThreadId, SP_BACKGROUND);
               }
           }

           //ALOGI(">>>> TRANSACT from pid %d uid %d\n", mCallingPid, mCallingUid);

           Parcel reply;
           status_t error;
           IF_LOG_TRANSACTIONS() {
               TextOutput::Bundle _b(alog);
               alog << "BR_TRANSACTION thr " << (void*)pthread_self()
                   << " / obj " << tr.target.ptr << " / code "
                   << TypeCode(tr.code) << ": " << indent << buffer
                   << dedent << endl
                   << "Data addr = "
                   << reinterpret_cast<const uint8_t*>(tr.data.ptr.buffer)
                   << ", offsets addr="
                   << reinterpret_cast<const size_t*>(tr.data.ptr.offsets) << endl;
           }
           if (tr.target.ptr) {

               //通过tr.coocke转换为BBinder,然后调用BBinder.transact方法
               // We only have a weak reference on the target object, so we must first try to
               // safely acquire a strong reference before doing anything else with it.
               if (reinterpret_cast<RefBase::weakref_type*>(
                       tr.target.ptr)->attemptIncStrong(this)) {
                   error = reinterpret_cast<BBinder*>(tr.cookie)->transact(tr.code, buffer,
                           &reply, tr.flags);
                   reinterpret_cast<BBinder*>(tr.cookie)->decStrong(this);
               } else {
                   error = UNKNOWN_TRANSACTION;
               }

           } else {
               error = the_context_object->transact(tr.code, buffer, &reply, tr.flags);
           }

           //ALOGI("<<<< TRANSACT from pid %d restore pid %d uid %d\n",
           //     mCallingPid, origPid, origUid);

           if ((tr.flags & TF_ONE_WAY) == 0) {
               LOG_ONEWAY("Sending reply to %d!", mCallingPid);
               if (error < NO_ERROR) reply.setError(error);
               sendReply(reply, 0);
           } else {
               LOG_ONEWAY("NOT sending reply to %d!", mCallingPid);
           }

           mCallingPid = origPid;
           mCallingUid = origUid;
           mStrictModePolicy = origStrictModePolicy;
           mLastTransactionBinderFlags = origTransactionBinderFlags;

           IF_LOG_TRANSACTIONS() {
               TextOutput::Bundle _b(alog);
               alog << "BC_REPLY thr " << (void*)pthread_self() << " / obj "
                   << tr.target.ptr << ": " << indent << reply << dedent << endl;
           }

       }
       break;
```
通过这行代码  error = reinterpret_cast<BBinder*>(tr.cookie)->transact(tr.code, buffer,
         &reply, tr.flags); ，我们可以看出来其实是调用了BBinder.transact方法，这里的BBinder是
         一个JavaBBinder，此类的定义如下
```java
class JavaBBinder : public BBinder
{
public:
    JavaBBinder(JNIEnv* env, jobject object)
        : mVM(jnienv_to_javavm(env)), mObject(env->NewGlobalRef(object))
    {
        ALOGV("Creating JavaBBinder %p\n", this);
        android_atomic_inc(&gNumLocalRefs);
        incRefsCreated(env);
    }

    bool    checkSubclass(const void* subclassID) const
    {
        return subclassID == &gBinderOffsets;
    }

    jobject object() const
    {
        return mObject;
    }

protected:
    virtual ~JavaBBinder()
    {
        ALOGV("Destroying JavaBBinder %p\n", this);
        android_atomic_dec(&gNumLocalRefs);
        JNIEnv* env = javavm_to_jnienv(mVM);
        env->DeleteGlobalRef(mObject);
    }

    virtual status_t onTransact(
        uint32_t code, const Parcel& data, Parcel* reply, uint32_t flags = 0)
    {
        JNIEnv* env = javavm_to_jnienv(mVM);

        ALOGV("onTransact() on %p calling object %p in env %p vm %p\n", this, mObject, env, mVM);

        IPCThreadState* thread_state = IPCThreadState::self();
        const int32_t strict_policy_before = thread_state->getStrictModePolicy();

        //printf("Transact from %p to Java code sending: ", this);
        //data.print();
        //printf("\n");
        jboolean res = env->CallBooleanMethod(mObject, gBinderOffsets.mExecTransact,
            code, reinterpret_cast<jlong>(&data), reinterpret_cast<jlong>(reply), flags);

        if (env->ExceptionCheck()) {
            jthrowable excep = env->ExceptionOccurred();
            report_exception(env, excep,
                "*** Uncaught remote exception!  "
                "(Exceptions are not yet supported across processes.)");
            res = JNI_FALSE;

            /* clean up JNI local ref -- we don't return to Java code */
            env->DeleteLocalRef(excep);
        }

        // Check if the strict mode state changed while processing the
        // call.  The Binder state will be restored by the underlying
        // Binder system in IPCThreadState, however we need to take care
        // of the parallel Java state as well.
        if (thread_state->getStrictModePolicy() != strict_policy_before) {
            set_dalvik_blockguard_policy(env, strict_policy_before);
        }

        if (env->ExceptionCheck()) {
            jthrowable excep = env->ExceptionOccurred();
            report_exception(env, excep,
                "*** Uncaught exception in onBinderStrictModePolicyChange");
            /* clean up JNI local ref -- we don't return to Java code */
            env->DeleteLocalRef(excep);
        }

        // Need to always call through the native implementation of
        // SYSPROPS_TRANSACTION.
        if (code == SYSPROPS_TRANSACTION) {
            BBinder::onTransact(code, data, reply, flags);
        }

        //aout << "onTransact to Java code; result=" << res << endl
        //    << "Transact from " << this << " to Java code returning "
        //    << reply << ": " << *reply << endl;
        return res != JNI_FALSE ? NO_ERROR : UNKNOWN_TRANSACTION;
    }

    virtual status_t dump(int fd, const Vector<String16>& args)
    {
        return 0;
    }

private:
    JavaVM* const   mVM;
    jobject const   mObject;
};
```
此类重写了onTransact方法，此方法中关键的一行代码
```java
jboolean res = env->CallBooleanMethod(mObject, gBinderOffsets.mExecTransact,
    code, reinterpret_cast<jlong>(&data), reinterpret_cast<jlong>(reply), flags);
```
此代码是调用java层和 gBinderOffsets.mExecTransact 对应的方法，此方法的注册代码为：
```java
gBinderOffsets.mExecTransact = GetMethodIDOrDie(env, clazz, "execTransact", "(IJJI)Z");
```
从这可以看出，其实是调用Binder里的exeTransact方法
```java
//Binder.java
// Entry point from android_util_Binder.cpp's onTransact
private boolean execTransact(int code, long dataObj, long replyObj,
        int flags) {
    Parcel data = Parcel.obtain(dataObj);
    Parcel reply = Parcel.obtain(replyObj);
    // theoretically, we should call transact, which will call onTransact,
    // but all that does is rewind it, and we just got these from an IPC,
    // so we'll just call it directly.
    boolean res;
    // Log any exceptions as warnings, don't silently suppress them.
    // If the call was FLAG_ONEWAY then these exceptions disappear into the ether.
    try {
        res = onTransact(code, data, reply, flags);
    } catch (RemoteException e) {
        if ((flags & FLAG_ONEWAY) != 0) {
            Log.w(TAG, "Binder call failed.", e);
        } else {
            reply.setDataPosition(0);
            reply.writeException(e);
        }
        res = true;
    } catch (RuntimeException e) {
        if ((flags & FLAG_ONEWAY) != 0) {
            Log.w(TAG, "Caught a RuntimeException from the binder stub implementation.", e);
        } else {
            reply.setDataPosition(0);
            reply.writeException(e);
        }
        res = true;
    } catch (OutOfMemoryError e) {
        // Unconditionally log this, since this is generally unrecoverable.
        Log.e(TAG, "Caught an OutOfMemoryError from the binder stub implementation.", e);
        RuntimeException re = new RuntimeException("Out of memory", e);
        reply.setDataPosition(0);
        reply.writeException(re);
        res = true;
    }
    checkParcel(this, code, reply, "Unreasonably large binder reply buffer");
    reply.recycle();
    data.recycle();

    // Just in case -- we are done with the IPC, so there should be no more strict
    // mode violations that have gathered for this thread.  Either they have been
    // parceled and are now in transport off to the caller, or we are returning back
    // to the main transaction loop to wait for another incoming transaction.  Either
    // way, strict mode begone!
    StrictMode.clearGatheredViolations();

    return res;
}
```
此方法调用了onTransact，而此方法被我们aidl文件生成的Stub类重写了
```java
@Override
public boolean onTransact(int code, android.os.Parcel data, android.os.Parcel reply, int flags) throws android.os.RemoteException {
    switch (code) {
        case INTERFACE_TRANSACTION: {
            reply.writeString(DESCRIPTOR);
            return true;
        }
        case TRANSACTION_getWeatherInfo: {
            data.enforceInterface(DESCRIPTOR);
            long _arg0;
            _arg0 = data.readLong();
            java.lang.String _result = this.getWeatherInfo(_arg0);
            reply.writeNoException();
            reply.writeString(_result);
            return true;
        }
    }
    return super.onTransact(code, data, reply, flags);
}
```
最后终于调到我们实现的方法了 <font color=#008B8B>java.lang.String _result = this.getWeatherInfo(_arg0);</font>
