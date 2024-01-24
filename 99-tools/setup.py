from setuptools import find_packages, setup

setup(
    name='job',
    version='0.0.1',
    packages=['jobtools', 'jobapi'],
    install_requires=[
        'boto3',
        'ruamel.yaml',
        'jinja2'
    ],
    entry_points={
        'console_scripts': [
            'submit=jobtools.submit:main',
            'lsjobs=jobtools.lsjobs:main',
            'lsqueues=jobtools.lsqueues:main'
        ]
    }
)

