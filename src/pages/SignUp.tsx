import { Button, Container, Input, Row } from '@nextui-org/react';
import { useState } from 'react';
import { useSignUp } from '../hooks/useAuth';


export default function SignUp() {
    const [loading, setLoading] = useState(false)
    const [email, setEmail] = useState('')
    console.log('email: ', email);
    const [password, setPassword] = useState('')
    console.log('password: ', password);
    const [{ error, fetching, session, user }, signIn] = useSignUp()
    const handleLogin = async (e: React.FormEvent<HTMLFormElement>) => {
        e.preventDefault()

        try {
            setLoading(true)
            await signIn({ email, password })
        } catch (error) {
            console.error(error)
        } finally {
            setLoading(false)
        }
    }

    if (error) return <div>Error signing in</div>
    if (fetching) return <div>Signing in</div>
    if (user) return <div>Logged in</div>

    return (
        <div >
            <Container fluid>
                <h1>Tasted</h1>
                <p>Sign up</p>
                {loading ? (
                    'Sending magic link...'
                ) : (
                    <form onSubmit={handleLogin}>
                        <Row align="center">
                            <Input
                                id="email"
                                type="email"
                                aria-label="email"
                                placeholder="Your email"
                                value={email}
                                onChange={(e) => setEmail(e.target.value)}
                            />
                        </Row>

                        <Row align="center">
                            <Input.Password aria-label="password" value={password} onChange={(e) => setPassword(e.target.value)} />
                        </Row>

                        <Button aria-live="polite" type='submit'>
                            Sign up
                        </Button>
                    </form>
                )}
            </Container>
        </div>
    )
}

